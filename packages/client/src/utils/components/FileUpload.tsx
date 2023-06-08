// Use this component if you want to have a button that opens a file dialog
// The contents of the file will be passed to the onFileUpload callback
import React, { ChangeEvent, useState } from "react";

interface Props {
  buttonText: string;
  onFileUpload: (fileText: string) => void;
}
const FileUpload: React.FC<Props> = ({ buttonText, onFileUpload }) => {
  const fileInputRef = React.useRef<HTMLInputElement>(null);
  const handleFileChange = (event: ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0];

    if (file) {
      const reader = new FileReader();
      reader.onload = handleFileRead;
      reader.readAsText(file);
    }
  };

  const handleFileRead = (event: ProgressEvent<FileReader>) => {
    const reader = event.target as FileReader;
    const fileText = reader.result as string;
    onFileUpload(fileText);
  };

  return (
    <div>
      <div
        className="p-5 w-full text-center bg-slate-700 mt-5 cursor-pointer"
        onClick={() => fileInputRef.current?.click()}
      >
        {buttonText}
      </div>
      <input
        ref={fileInputRef}
        className="hidden"
        type="file"
        onChange={handleFileChange}
      />
    </div>
  );
};

export default FileUpload;
