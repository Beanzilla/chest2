# Chest2

The Advanced Chest mod

## What's in the box

- A chest (single node, but unlike all other chests, somewhat larger inventory size, but gains paging, so you get multiple inventories in 1 chest)
- Simple to use features
- Settings by `minetest.conf`
- A remote (Access your Chest2 chests via remote)

## How the `chest2:chest` differs from say `default:chest`?

While a standard chest requires you to make keys for others to access it too, Chest2 simply requires the `Members` setting and 1 player name per line (that's `bob123` or `tv_frank` but one on each line, then click Save)

While a standard chest is 8x3 the Chest2 is 12x5 not to mention Chest2 supports multiple pages (which are seperate inventories, so 12x5 times each page)

While there is no way to remotely access a standard chest, Chest2 comes with a Remote, just punch a `chest2:chest` with the remote to connect it to that Chest, then from there punch (left click), use (right click) to access that chest from anywhere in the world (unlimited distance included).

> Note, the remote will reset to a unconnected remote if it looses connection/i.e. someone broke the chest/moved the chest. (When the mod refers to chest it refers to `chest2:chest`)

## Settings

This mod comes with almost full customization from crafting a remote, to crafting a `chest2:chest`, even the number of pages in a `chest2:chest`.

Just run this mod, (it auto-generates the settings into your `minetest.conf`),
then edit `minetest.conf` or for singleplayer worlds change it via Minetest Settings (under the Mods section will be Chest2)

