import React from "react";

export const SearchBar: React.FC<{
  inputLabel?: string;
  value?: string | number | readonly string[];
  onChange?: React.ChangeEventHandler<HTMLInputElement>;
}> = ({ inputLabel, value, onChange }) => {
  const searchLabel = inputLabel || "Search";
  
  React.useEffect(() => {
    const style = document.createElement("style");
    style.innerHTML = `
      input[type="search"]::-webkit-search-decoration,
      input[type="search"]::-webkit-search-cancel-button,
      input[type="search"]::-webkit-search-results-button,
      input[type="search"]::-webkit-search-results-decoration {
        display: none;
      }
      input[type="search"]::-ms-clear {
        display: none;
      }
      input[type="search"]:hover, input[type="search"]:focus {
        border-color: #9BA3AF;
      }
    `;
    document.head.appendChild(style);
    return () => {
      document.head.removeChild(style);
    };
  }, []);

  const searchLabelColor = "#9BA3AF"; // Change this to the desired color of the search label

  return (
    <>
      <div className="relative w-full">
        <div className="absolute inset-y-0 left-0 flex items-center pl-3 pointer-events-none">
          <svg
            className="w-4 h-4"
            style={{ color: searchLabelColor }}
            aria-hidden="true"
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 20 20"
          >
            <path
              stroke="currentColor"
              strokeLinecap="round"
              strokeLinejoin="round"
              strokeWidth="2"
              d="m19 19-4-4m0-7A7 7 0 1 1 1 8a7 7 0 0 1 14 0Z"
            />
          </svg>
        </div>
        <input
          type="search"
          id="search"
          className="block w-full p-4 pl-10 text-sm rounded focus:outline-none focus:ring-0 appearance-none"
          style={{ color: searchLabelColor, backgroundColor: "#374147", border: '1px solid transparent' }}
          placeholder={searchLabel}
          value={value}
          onChange={onChange}
          required
        />
      </div>
    </>
  );
};
