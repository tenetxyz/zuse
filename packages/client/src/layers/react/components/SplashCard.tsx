import { registerTenetComponent } from "../engine/components/TenetComponentRenderer";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faFileCircleQuestion } from "@fortawesome/free-solid-svg-icons";
import { faTwitter, faDiscord } from "@fortawesome/free-brands-svg-icons";

export const registerSplashCard = () => {
  registerTenetComponent({
    rowStart: 1,
    rowEnd: 1,
    columnStart: 1,
    columnEnd: 4,
    Component: () => {
      return (
        // "pointerEvents: all" is needed so when we click on the admin panel, we don't gain focus on the noa canvasvoxelTypes = creationTable.voxelTypes.get(creationId)
        <div className="flex flex-col w-fit bg-slate-600 p-5" style={{ pointerEvents: "all" }}>
          <div className="inline-flex">
            <div className="flex flex-row justify-end items-baseline">
              <p className="text-2xl">Everlon</p>
              <p className="text-md ml-2">v0.0.1</p>
            </div>
            <div className="ml-3 flex gap-3 items-center">
              {/* <FontAwesomeIcon icon={faDiscord} className="mr-2" /> */}
              <a
                href="https://tenetxyz.notion.site/Everlon-Blocks-WIP-1f5283c562994c019aa123336331793c"
                target="_blank"
                rel="noreferrer"
              >
                <FontAwesomeIcon icon={faFileCircleQuestion} className="cursor-pointer hover:text-[#1DA1F2]" />
              </a>
              <a href="https://twitter.com/tenetxyz" target="_blank" rel="noreferrer">
                <FontAwesomeIcon icon={faTwitter} className="cursor-pointer hover:text-[#1DA1F2]" />
              </a>
            </div>
          </div>
          <div>
            <p className="text-sm mt-2">Press '-' to open the creations sidebar</p>
          </div>
        </div>
      );
    },
  });
};
