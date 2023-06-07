# Voxel AW

### Running locally

1. Run `pnpm install` to install dependencies
2. Run `pnpm run dev` in the top directory

### Linking MUD

We've forked MUD so we can modify some of the packages. Currently the following packages are being used from the fork:

- `recs`

Here are the steps to link the local MUD package.

1. git clone our fork of mud a directory above the root directory for this project
2. For each package listed above
   - cd into it (eg `cd packages/recs`)
   - run `pnpm install`
   - run `pnpm build`

That's it! Everytime you change a file in the package, just remember to `pnpm build`.
