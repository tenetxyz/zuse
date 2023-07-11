import { registerTenetComponent } from "../engine/components/TenetComponentRenderer";
import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import { faTwitter, faDiscord } from "@fortawesome/free-brands-svg-icons";

export const registerSplashCard = () => {
  registerTenetComponent({
    rowStart: 1,
    rowEnd: 3,
    columnStart: 1,
    columnEnd: 2,
    Component: () => {
      return (
        <div className="flex flex-row bg-slate-600 p-5">
          <p className="font-md">Everlon</p>
          <p>v0.0.1</p>
          <FontAwesomeIcon icon={faDiscord} />
          <FontAwesomeIcon icon={faTwitter} />
          {/* <FontAwesomeIcon icon="fa-brands fa-discord" /> */}
        </div>
      );
    },
  });
};
