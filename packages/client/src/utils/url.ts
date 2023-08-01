// sets the url param and returns the new url
export const setUrlParam = (currentURL: string, paramName: string, paramValue: string) => {
  // Check if the parameter already exists in the URL
  if (currentURL.includes(`${paramName}=`)) {
    // Update the existing parameter with the new value
    const re = new RegExp(`${paramName}=([^&]*)`);
    return currentURL.replace(re, `${paramName}=${paramValue}`);
  } else {
    // If the parameter doesn't exist, add it to the URL
    return currentURL + (currentURL.includes("?") ? "&" : "?") + `${paramName}=${paramValue}`;
  }
};
