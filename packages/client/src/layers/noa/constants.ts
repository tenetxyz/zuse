import { VoxelCoord } from "@latticexyz/utils";
import { NoaVoxelDef, NoaBlockType } from "./types";

export const CRAFTING_SIDE = 3;
// export const SPAWN_POINT: VoxelCoord = { x: -1543, y: 11, z: -808 };
export const SPAWN_POINT: VoxelCoord = { x: 0, y: 11, z: 0 };
export const CRAFTING_SIZE = CRAFTING_SIDE * CRAFTING_SIDE;
export const EMPTY_CRAFTING_TABLE = [...new Array(CRAFTING_SIZE)].map(() => -1);
export const MINING_DURATION = 300;
export const FAST_MINING_DURATION = 200;
export const GRAVITY_MULTIPLIER = 2;

const nftStorageLinkFormat = "https://${hash}.ipfs.nftstorage.link/";

export function getNftStorageLink(hash: string) {
  return nftStorageLinkFormat.replace("${hash}", hash);
}

export const Textures = {
  Grass: getNftStorageLink("bafkreidtk7vevmnzt6is5dreyoocjkyy56bk66zbm5bx6wzck73iogdl6e"),
  GrassSide: getNftStorageLink("bafkreien7wqwfkckd56rehamo2riwwy5jvecm5he6dmbw2lucvh3n4w6ue"),
  Dirt: getNftStorageLink("bafkreihy3pblhqaqquwttcykwlyey3umpou57rkvtncpdrjo7mlgna53g4"),
  Bedrock: getNftStorageLink("bafkreidfo756faklwx7o4q2753rxjqx6egzpmqh2zhylxaehqalvws555a"),
  Tile2: getNftStorageLink("bafkreidfo756faklwx7o4q2753rxjqx6egzpmqh2zhylxaehqalvws555a"),
  Tile3: getNftStorageLink("bafkreidfo756faklwx7o4q2753rxjqx6egzpmqh2zhylxaehqalvws555a"),
  Tile4: getNftStorageLink("bafkreidfo756faklwx7o4q2753rxjqx6egzpmqh2zhylxaehqalvws555a"),
};

export const UVWraps = {
  Air: undefined,
  Grass: getNftStorageLink("bafkreiewghdyhnlq4yiqe4umxaytoy67jw3k65lwll2rbomfzr6oivhvpy"),
  Dirt: getNftStorageLink("bafkreifsrs64rckwnfkwcyqkzpdo3tpa2at7jhe6bw7jhevkxa7estkdnm"),
  Bedrock: getNftStorageLink("bafkreihdit6glam7sreijo7itbs7uwc2ltfeuvcfaublxf6rjo24hf6t4y"),
  Tile2: getNftStorageLink("bafkreidfo756faklwx7o4q2753rxjqx6egzpmqh2zhylxaehqalvws555a"),
  Tile3: getNftStorageLink("bafkreidfo756faklwx7o4q2753rxjqx6egzpmqh2zhylxaehqalvws555a"),
  Tile4: getNftStorageLink("bafkreidfo756faklwx7o4q2753rxjqx6egzpmqh2zhylxaehqalvws555a"),
};
