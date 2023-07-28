import { useComponentUpdate } from "@/utils/useComponentUpdate";
import { Layers } from "../../../types";
import { SearchBar } from "./common/SearchBar";
import { useWorldRegistrySearch } from "@/utils/useWorldRegistrySearch";
import { to40CharAddress } from "@/utils/entity";
import { VoxelTypeDesc } from "./VoxelTypeStore";
import { VoxelBaseTypeId } from "@/layers/noa/types";
import { useState, useRef } from 'react';
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { CardStackMinusIcon } from "@radix-ui/react-icons";

type CaAddress = string;
export interface WorldRegistryFilters {
  query: string;
}
export interface WorldDesc {
  worldAddress: string;
  name: string;
  description: string;
  creator: string;
  caAddresses: CaAddress[];
}

export interface CaDesc {
  caAddress: string;
  name: string;
  description: string;
  creator: string;
  scale: number;
  voxelBaseTypeIds: string[];
}

export type CaDescs = Map<CaAddress, CaDesc>;
export type VoxelTypeDescs = Map<VoxelBaseTypeId, VoxelTypeDesc>;

interface Props {
  layers: Layers;
  filters: WorldRegistryFilters;
  setFilters: React.Dispatch<React.SetStateAction<WorldRegistryFilters>>;
}

export const WorldRegistry = ({ layers, filters, setFilters }: Props) => {
  const {
    network: {
      registryComponents: { CARegistry, VoxelTypeRegistry },
      getVoxelIconUrl
    },
  } = layers;
  const { worldsToDisplay } = useWorldRegistrySearch({ layers, filters });

  const caDescs = useRef<CaDescs>(new Map());
  const voxelTypeDescs = useRef<VoxelTypeDescs>(new Map());

  const [details, setDetails] = useState<CaDesc[] | null>(null);

  useComponentUpdate(CARegistry, (update) => {
    const caDesc = update.value[0];
    if (!caDesc) {
      console.warn(`cannot find values for ${update.entity}`);
      return;
    }
    const caAddress = to40CharAddress(update.entity);
    caDescs.current.set(caAddress, {
      caAddress,
      name: caDesc.name,
      description: caDesc.description,
      creator: caDesc.creator,
      scale: caDesc.scale,
      voxelBaseTypeIds: caDesc.voxelTypeIds,
    } as CaDesc);
  });

  useComponentUpdate(VoxelTypeRegistry, (update) => {
    const voxelTypeDesc = update.value[0];
    if (!voxelTypeDesc) {
      console.warn(`cannot find values for ${update.entity}`);
      return;
    }
    const voxelBaseTypeId = update.entity;
    voxelTypeDescs.current.set(voxelBaseTypeId, {
      voxelBaseTypeId,
      name: voxelTypeDesc.name,
      previewVoxelVariantId: voxelTypeDesc.previewVoxelVariantId,
      numSpawns: voxelTypeDesc.numSpawns,
      creator: voxelTypeDesc.creator,
      scale: voxelTypeDesc.scale,
      childVoxelTypeIds: voxelTypeDesc.childVoxelTypeIds,
    } as VoxelTypeDesc);
  });

  return (
    <div className="flex flex-col p-4">
      <div className="flex w-full">
        <SearchBar value={filters.query} onChange={(e) => setFilters({ ...filters, query: e.target.value })} />
      </div>
      <div className="flex flex-col gap-5 mt-5 mb-4 w-full h-full justify-start items-center overflow-scroll">
        {worldsToDisplay.map((world, idx) => {
          return (
            <div key={"world-" + idx} className="w-full p-6 bg-white border border-gray-200 rounded-lg shadow">
              <h5 className="mb-2 text-2xl font-bold tracking-tight text-gray-900">{world.name}</h5>
              <p className="font-normal text-gray-700 leading-4">{world.description}</p>
              <p className="font-normal text-gray-700 leading-4 mt-4">{world.worldAddress}</p>
              <div className="flex mt-5 gap-2">
                <button
                  type="button"
                  // onClick={() => {
                  //   spawnCreation(creation);
                  // }}
                  className="focus:outline-none text-white bg-green-700 hover:bg-green-800 focus:ring-4 focus:ring-green-300 font-medium rounded-lg text-sm px-5 py-2.5 mr-2 mb-2"
                >
                  Connect
                </button>
                <button
                  type="button"
                  onClick={() => {
                    let detailsArray: CaDesc[] = [];
                    for (const caAddress of world.caAddresses) {
                      const caDesc = caDescs.current.get(caAddress);
                      if (caDesc) {
                        detailsArray.push(caDesc);
                      }
                    }
                    setDetails(detailsArray.length > 0 ? detailsArray : null);
                  }}
                  className="text-gray-900 hover:text-white border border-gray-800 hover:bg-gray-900 focus:ring-4 focus:outline-none focus:ring-gray-300 font-medium rounded-lg text-sm px-5 py-2.5 text-center mr-2 mb-2"
                >
                  View Details
                </button>
              </div>
              {details && (
                <div style={{color: "black"}}>
                  {details.sort((a, b) => b.scale - a.scale).map((detail, idx) => (
                    <Card key={idx} style={{marginBottom: "8px"}}>
                      <CardHeader>
                        <CardTitle>{detail.name}</CardTitle>
                        <CardDescription>{detail.description}</CardDescription>
                        <Badge variant="outline" className="rounded" style={{width: "fit-content"}}> Creator: {detail.creator.slice(0, 10)}... </Badge>
                      </CardHeader>
                      <CardContent>
                        <div style={{display: 'grid', gridTemplateColumns: 'repeat(auto-fill, minmax(32px, 1fr))', gap: '2px'}}>
                          {detail.voxelBaseTypeIds.map(voxelBaseTypeId => {
                            const iconUrl = getVoxelIconUrl(voxelBaseTypeId);
                            return iconUrl && <img src={iconUrl} alt={detail.name} style={{width: '32px', height: '32px'}} /> // Render the image
                          })}
                        </div>
                      </CardContent>
                    </Card>
                  ))}
                </div>
              )}
            </div>
          );
        })}
      </div>


    </div>
  );
};
