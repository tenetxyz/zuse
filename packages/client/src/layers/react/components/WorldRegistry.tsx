import { useComponentUpdate } from "@/utils/useComponentUpdate";
import { Layers } from "../../../types";
import { SearchBar } from "./common/SearchBar";
import { useWorldRegistrySearch } from "@/utils/useWorldRegistrySearch";
import { to40CharAddress } from "@/utils/entity";
import { VoxelTypeDesc } from "./VoxelTypeStore";
import { VoxelBaseTypeId } from "@/layers/noa/types";
import { useState, useRef } from "react";
import { Card, CardContent, CardDescription, CardFooter, CardHeader, CardTitle } from "@/components/ui/card";
import { Badge } from "@/components/ui/badge";
import { CardStackMinusIcon } from "@radix-ui/react-icons";
import { Button } from "@/components/ui/button";
import { Collapsible, CollapsibleContent, CollapsibleTrigger } from "@/components/ui/collapsible";
import { CaretSortIcon } from "@radix-ui/react-icons";
import { Separator } from "@/components/ui/separator";
import { setUrlParam } from "@/utils/url";

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
      getVoxelIconUrl,
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
      <div style={{ background: "#24292E" }} className="mt-4 mb-2">
        {worldsToDisplay.map((world, idx) => {
          return (
            <Card key={"world-" + idx} className="rounded" style={{ border: "1px solid #374147" }}>
              <div className="flex flex-col">
                <Collapsible>
                  <div className="flex items-center justify-between ">
                    <CardHeader>
                      <CardTitle>{world.name}</CardTitle>
                      <CardDescription>{world.description}</CardDescription>
                    </CardHeader>
                    <CollapsibleTrigger asChild>
                      <Button
                        variant="ghost"
                        size="sm"
                        className="rounded mr-4 hover:bg-slate-500 ..."
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
                      >
                        <CaretSortIcon className="h-4 w-4" />
                        <span className="sr-only">Toggle</span>
                      </Button>
                    </CollapsibleTrigger>
                  </div>
                  <CollapsibleContent>
                    <CardContent>
                      {details && (
                        <div>
                          {details
                            .sort((a, b) => b.scale - a.scale)
                            .map((detail, idx) => (
                              <div key={`world-details-${idx}`}>
                                <div className="flex justify-between space-x-4">
                                  <div className="space-y-1">
                                    <h4 className="text-sm font-black">{detail.name}</h4>
                                    <p className="text-xs font-medium">{detail.description}</p>
                                    <div
                                      style={{
                                        display: "grid",
                                        gridTemplateColumns: "repeat(auto-fill, minmax(24px, 1fr))",
                                        gap: "1px",
                                      }}
                                    >
                                      {detail.voxelBaseTypeIds.map((voxelBaseTypeId) => {
                                        const iconUrl = getVoxelIconUrl(voxelBaseTypeId);
                                        return (
                                          iconUrl && (
                                            <img
                                              key={`world-details-${idx}-voxelBaseTypeId-${voxelBaseTypeId}`}
                                              src={iconUrl}
                                              alt={detail.name}
                                              style={{
                                                width: "24px",
                                                height: "24px",
                                                borderRadius: "2px",
                                                border: "1px solid #374147",
                                              }}
                                            />
                                          )
                                        ); // Render the image
                                      })}
                                    </div>
                                  </div>
                                </div>
                                {idx < details.length - 1 && (
                                  <Separator className="my-4" style={{ background: "#374147" }} />
                                )}{" "}
                                {/* Add condition here */}
                              </div>
                            ))}
                        </div>
                      )}
                    </CardContent>
                  </CollapsibleContent>
                </Collapsible>
                <Button
                  className="ml-4 mr-4 bg-amber-400 hover:bg-amber-500 text-slate-600 font-bold mb-4 rounded"
                  onClick={() => {
                    // Redirect to the new URL
                    window.location.href = setUrlParam(window.location.href, "worldAddress", world.worldAddress);
                  }}
                >
                  {" "}
                  Connect{" "}
                </Button>
              </div>
            </Card>
          );
        })}
      </div>
    </div>
  );
};
