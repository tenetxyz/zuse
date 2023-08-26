import { Scene, Sound, Vector3 } from "@babylonjs/core";
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
import { euclidean, isNotEmpty, pickRandom, keccak256, awaitStreamValue } from "@latticexyz/utils";
import { timer } from "rxjs";
import { NetworkLayer } from "../../network";
import { NoaLayer, VoxelTypeKey } from "../types";
import { AIR_ID } from "../../network/api/terrain/occurrence";
import { getWorldScale } from "../../../utils/coord";
import { to64CharAddress } from "../../../utils/entity";

export function createSoundSystem(network: NetworkLayer, context: NoaLayer) {
  const {
    contractComponents: { VoxelType, Position },
    api: { getTerrainVoxelTypeAtPosition },
    streams: { doneSyncing$ },
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
    sound.onended = () => updateComponent(Sounds, SingletonEntity, { playingTheme: undefined });
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

    const prevSound = prevPlayingTheme ? scene.getSoundByName(prevPlayingTheme) : undefined;
    const newSound = playingTheme ? scene.getSoundByName(playingTheme) : undefined;

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

  let isDoneSyncingWorlds = false;
  awaitStreamValue(doneSyncing$, (isDoneSyncing) => isDoneSyncing).then(() => {
    isDoneSyncingWorlds = true;
  });

  defineSystem(
    world,
    [Has(Position), Has(VoxelType)],
    (update) => {
      // Don't play sounds during initial loading
      if (!isDoneSyncingWorlds) return;

      // Get data
      const { x, y, z } = playerPosition$.getValue();
      const playerPosArr = [x, y, z];
      const voxelType = (
        update.type === UpdateType.Exit && isComponentUpdate(update, VoxelType)
          ? update.value[1]?.value
          : getComponentValue(VoxelType, update.entity)
      ) as VoxelTypeKey | undefined;

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
      let voxelBaseTypeId = voxelType.voxelBaseTypeId;
      let updateType = update.type;

      // When mining a terrain voxel, we get an ECS update for an entering air voxel instead
      // Hack: entity id is the same as entity index for optimistic updates
      if (update.type == UpdateType.Enter && voxelBaseTypeId === AIR_ID) {
        // const isOptimisticUpdate = world.entities[update.entity] == (update.entity as unknown);
        const isOptimisticUpdate = update.entity == (update.entity as unknown);
        if (!isOptimisticUpdate) return;
        voxelBaseTypeId = getTerrainVoxelTypeAtPosition(position, getWorldScale(noa)).voxelBaseTypeId;
        updateType = UpdateType.Exit;
      }

      const sound: Sound | undefined = (() => {
        if (updateType === UpdateType.Exit) {
          // TODO: this logic feels wrong. I think an id is an int, not a string
          if (voxelBaseTypeId.includes("Wool")) return effect["break"].Wool;
          if (["Log", "Planks"].includes(voxelBaseTypeId)) return effect["break"].Wood;
          if (["Diamond", "Coal"].includes(voxelBaseTypeId)) return effect["break"].Metal;
          if (["Stone", "Cobblestone", "MossyCobblestone"].includes(voxelBaseTypeId)) return effect["break"].Stone;
          return effect["break"][voxelBaseTypeId as keyof (typeof effect)["break"]] || effect["break"].Dirt;
        }

        if (updateType === UpdateType.Enter) {
          if (["Log", "Planks"].includes(voxelBaseTypeId)) return effect["place"].Wood;
          if (["Diamond", "Coal"].includes(voxelBaseTypeId)) return effect["place"].Metal;
          if (["Stone", "Cobblestone", "MossyCobblestone"].includes(voxelBaseTypeId)) return effect["place"].Stone;
          return effect["place"][voxelBaseTypeId as keyof (typeof effect)["place"]] || effect["place"].Dirt;
        }
      })();

      // Play sound
      sound?.setPosition(voxelPosVec);
      sound?.play();
    },
    { runOnInit: false }
  );
}
