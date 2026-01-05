Basic usage
===

- Add the dependency to your project's `.zon` file: `zig fetch --save git+https://github.com/tcgdex/zig-sdk`

- Add the library to your code

```zig
const dependeny = b.dependency("sdk", .{}); // both args are optional
const module = dependency.module("sdk");
your_module.addImport("sdk", module);
```

- Use it, eg:

```zig
// configure the sdk for a language, .en==english
const sdk = @import("sdk").For(.en);

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
