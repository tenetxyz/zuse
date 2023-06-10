import { Scene, Sound, Vector3 } from "@babylonjs/core";
import { SyncState } from "@latticexyz/network";
import {
  defineComponentSystem,
  defineRxSystem,
  defineSystem,
  Entity,
  getComponentValue,
  Has,
  isComponentUpdate,
  updateComponent,
  UpdateType,
} from "@latticexyz/recs";
import { euclidean, isNotEmpty, pickRandom } from "@latticexyz/utils";
import { timer } from "rxjs";
import { VoxelTypeKeyToId, NetworkLayer } from "../../network";
import { VoxelTypeIdToKey } from "../../network/constants";
import { NoaLayer } from "../types";

export function createSoundSystem(network: NetworkLayer, context: NoaLayer) {
  const {
    components: { LoadingState },
    contractComponents: { VoxelType, Position },
    api: { getTerrainVoxelTypeAtPosition },
  } = network;
  const {
    audioEngine,
    components: { Sounds },
    SingletonEntity,
    world,
    noa,
    streams: { playerPosition$ },
  } = context;
  if (!audioEngine) return console.warn("No audio engine found");
  const scene: Scene = noa.rendering.getScene();
  const musicUrls = [
    "/audio/OP_World_Theme_Mix_1.mp3",
    "/audio/Berceuse_Mix_2.mp3",
    "/audio/Gymnopedia_Mix_3.mp3",
    "/audio/OP_World_2.mp3",
  ];

  // Set the position of the audio listener
  scene.audioListenerPositionProvider = () => {
    const pos = playerPosition$.getValue();
    return new Vector3(pos.x, pos.y, pos.z);
  };

  // Register custom button
  audioEngine.useCustomUnlockedButton = true;

  // Register music
  const themes = musicUrls.map((url, index) => {
    const sound: Sound = new Sound("theme" + index, url, null, null, {
      volume: 0.5,
    });
    sound.onended = () =>
      updateComponent(Sounds, SingletonEntity, { playingTheme: undefined });
    return sound.name;
  });
  updateComponent(Sounds, SingletonEntity, { themes });

  function registerSoundEffect(name: string) {
    return new Sound(name, `/audio/effects/${name}.mp3`, null, null, {
      spatialSound: true,
      distanceModel: "exponential",
      volume: 1,
    });
  }

  // Register sound effects
  const effect = {
    break: {
      Dirt: registerSoundEffect("break/dirt"),
      Glass: registerSoundEffect("break/glass"),
      Leaves: registerSoundEffect("break/leaves"),
      Metal: registerSoundEffect("break/metal"),
      Stone: registerSoundEffect("break/stone"),
      Wood: registerSoundEffect("break/wood"),
      Wool: registerSoundEffect("break/wool"),
    },
    place: {
      Dirt: registerSoundEffect("place/dirt"),
      Metal: registerSoundEffect("place/metal"),
      Sand: registerSoundEffect("place/sand"),
      Stone: registerSoundEffect("place/stone"),
      Wood: registerSoundEffect("place/wood"),
    },
  };

  // Start a new theme if the `playingTheme` value changes
  defineComponentSystem(world, Sounds, (update) => {
    const prevPlayingTheme = update.value[1]?.playingTheme;
    const playingTheme = update.value[0]?.playingTheme;

    const prevSound = prevPlayingTheme
      ? scene.getSoundByName(prevPlayingTheme)
      : undefined;
    const newSound = playingTheme
      ? scene.getSoundByName(playingTheme)
      : undefined;

    prevSound?.stop();
    newSound?.play();
  });

  // TODO: re-enable music. I muted the music cause it's annoying
  // Set a new `playingTheme` in random intervals if none is playing
  // defineRxSystem(world, timer(0, 60000), () => {
  //   const currentlyPlaying = getComponentValue(Sounds, SingletonEntity)?.playingTheme;
  //   if (!currentlyPlaying && Math.random() < 0.5) {
  //     const playingTheme = (isNotEmpty(themes) && pickRandom(themes)) || undefined;
  //     updateComponent(Sounds, SingletonEntity, { playingTheme });
  //   }
  // });

  defineSystem(
    world,
    [Has(Position), Has(VoxelType)],
    (update) => {
      // Don't play sounds during initial loading
      if (
        getComponentValue(LoadingState, SingletonEntity)?.state !==
        SyncState.LIVE
      )
        return;

      // Get data
      const { x, y, z } = playerPosition$.getValue();
      const playerPosArr = [x, y, z];
      const voxelType =
        update.type === UpdateType.Exit && isComponentUpdate(update, VoxelType)
          ? update.value[1]?.value
          : getComponentValue(VoxelType, update.entity)?.value;

      const position =
        update.type === UpdateType.Exit && isComponentUpdate(update, Position)
          ? update.value[1]
          : getComponentValue(Position, update.entity);

      if (!voxelType || !position) return;

      // Only care about close events
      const voxelPosArr = [position.x, position.y, position.z];
      const distance = euclidean(playerPosArr, voxelPosArr);
      if (distance > 32) return;

      const voxelPosVec = new Vector3(...voxelPosArr);

      // Find sound to play
      let voxelTypeKey = VoxelTypeIdToKey[voxelType as Entity];
      let updateType = update.type;

      // When mining a terrain voxel, we get an ECS update for an entering air voxel instead
      // Hack: entity id is the same as entity index for optimistic updates
      if (
        update.type == UpdateType.Enter &&
        voxelType === VoxelTypeKeyToId.Air
      ) {
        // const isOptimisticUpdate = world.entities[update.entity] == (update.entity as unknown);
        const isOptimisticUpdate = update.entity == (update.entity as unknown);
        if (!isOptimisticUpdate) return;
        voxelTypeKey = VoxelTypeIdToKey[getTerrainVoxelTypeAtPosition(position)];
        updateType = UpdateType.Exit;
      }

      const sound: Sound | undefined = (() => {
        if (updateType === UpdateType.Exit) {
          if (voxelTypeKey.includes("Wool")) return effect["break"].Wool;
          if (["Log", "Planks"].includes(voxelTypeKey))
            return effect["break"].Wood;
          if (["Diamond", "Coal"].includes(voxelTypeKey))
            return effect["break"].Metal;
          if (
            ["Stone", "Cobblestone", "MossyCobblestone"].includes(voxelTypeKey)
          )
            return effect["break"].Stone;
          return (
            effect["break"][voxelTypeKey as keyof typeof effect["break"]] ||
            effect["break"].Dirt
          );
        }

        if (updateType === UpdateType.Enter) {
          if (["Log", "Planks"].includes(voxelTypeKey))
            return effect["place"].Wood;
          if (["Diamond", "Coal"].includes(voxelTypeKey))
            return effect["place"].Metal;
          if (
            ["Stone", "Cobblestone", "MossyCobblestone"].includes(voxelTypeKey)
          )
            return effect["place"].Stone;
          return (
            effect["place"][voxelTypeKey as keyof typeof effect["place"]] ||
            effect["place"].Dirt
          );
        }
      })();

      // Play sound
      sound?.setPosition(voxelPosVec);
      sound?.play();
    },
    { runOnInit: false }
  );
}
