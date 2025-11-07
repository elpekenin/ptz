WIP library to interact with the Pokemon TCG database at tcgdex.net

Name stands for **P**okemon **T**cg in **Z**ig

Basic usage:
1. List the dependency on project's `.zon` file: `zig fetch --save https://github.com/elpekenin/ptz`

2. Add the library to your code
```zig
const dependeny = b.dependency("ptz", .{}); // both args are optional
const module = dependency.module("ptz");
your_module.addImport("ptz", module);
```

3. Use it, eg:
```zig
const sdk = @import("ptz").sdk(.en); // configure a language, en=english

// create an iterator to go through all cards with "machamp" in their name
var iterator = sdk.Card.all(.{
    .where = &.{
        .like(.name, "machamp" ),
    },
});

// get the first batch
const briefs = if (try iterator.next()) |briefs|
    briefs
else
    return error.NoCardsFound;

// don't forget to free memory!
defer {
    for (briefs) |brief| {
        brief.deinit();
    }
}

// get full info for the first card
const card: sdk.Card = try .get(allocator, .{
    .id = briefs[0].id,
});
defer card.deinit();

// show it
try writer.print("{f}", .{card});
```
