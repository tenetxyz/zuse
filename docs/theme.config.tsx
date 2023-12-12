import React from "react";
import { DocsThemeConfig } from "nextra-theme-docs";

const config: DocsThemeConfig = {
  logo: <span>Zuse</span>,
  project: {
    link: "https://github.com/tenetxyz/zuse",
  },
  chat: {
    link: "https://discord.com",
  },
  docsRepositoryBase: "https://github.com/tenetxyz/zuse/tree/main/docs",
  footer: {
    text: "MIT 2023",
  },
};

export default config;
