import React from "react";
import { DocsThemeConfig } from "nextra-theme-docs";
import { useRouter } from "next/router";

const config: DocsThemeConfig = {
  logo: <span>Zuse</span>,
  useNextSeoProps() {
    const { asPath } = useRouter();
    return {
      titleTemplate:
        asPath === "/" ? "ZUSE - a framework for building worlds with strong digital physics" : "%s - ZUSE",
    };
  },
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
