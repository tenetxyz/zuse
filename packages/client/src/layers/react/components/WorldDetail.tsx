import { Layers } from "@/types";
import { CaDesc, CaDescs, VoxelTypeDescs, WorldDesc } from "./WorldRegistry";
import { Ref } from "@/utils/types";
import { VoxelTypeDesc } from "./VoxelTypeStore";

interface Props {
  worldDesc: WorldDesc;
  caDescs: Ref<CaDescs>;
  voxelTypeDescs: Ref<VoxelTypeDescs>;
}
export const WorldDetail = ({ caDescs, voxelTypeDescs, worldDesc }: Props) => {
  const caDescsForWorld = worldDesc.caAddresses
    .map((caAddress) => {
      const caDesc = caDescs.current.get(caAddress);
      if (!caDesc) {
        console.warn("cannot find caDesc for", caAddress);
        return null;
      }
      return caDesc;
    })
    .filter((caDesc) => caDesc !== null) as CaDesc[];
  caDescsForWorld.sort((a, b) => a.scale - b.scale);
  return (
    <div>
      <h1>World Detail</h1>
      <p>World Address: {worldDesc.worldAddress}</p>
      <p>Name: {worldDesc.name}</p>
      <p>Description: {worldDesc.description}</p>
      <p>Creator: {worldDesc.creator}</p>
      <p>CA Addresses</p>
      {caDescsForWorld.map((caAddress, caIdx) => {
        const voxelTypeDescsForCa = caAddress.voxelBaseTypeIds
          .map((voxelBaseTypeId) => {
            const voxelTypeDesc = voxelTypeDescs.current.get(voxelBaseTypeId);
            if (!voxelTypeDesc) {
              console.warn("cannot find voxelTypeDesc for", voxelBaseTypeId);
              return null;
            }
            return voxelTypeDesc;
          })
          .filter((voxelTypeDesc) => voxelTypeDesc !== null) as VoxelTypeDesc[];
        return (
          <div key={`world-address-${worldDesc.worldAddress}-ca-${caIdx}`}>
            <p>CA Address: {caAddress.caAddress}</p>
            <p>Name: {caAddress.name}</p>
            <p>Description: {caAddress.description}</p>
            <p>Creator: {caAddress.creator}</p>
            <p>Scale: {caAddress.scale}</p>
            <p>Voxel Base Type Ids</p>
            {voxelTypeDescsForCa.map((voxelTypeDesc, voxelTypeIdx) => {
              return (
                <div key={`world-address-${worldDesc.worldAddress}-ca-${caIdx}-voxel-type-${voxelTypeIdx}`}>
                  <p>Voxel Base Type Id: {voxelTypeDesc.voxelBaseTypeId}</p>
                  <p>Name: {voxelTypeDesc.name}</p>
                  <p>Creator: {voxelTypeDesc.creator}</p>
                  {/* <p>Scale: {voxelTypeDesc.scale}</p> */}
                  name: string; VoxelBaseTypeId: Entity; previewVoxelVariantId: string; numSpawns: BigInt; creator:
                  string; scale: number; childVoxelTypeIds: string[];
                </div>
              );
            })}
          </div>
        );
      })}
    </div>
  );
};
