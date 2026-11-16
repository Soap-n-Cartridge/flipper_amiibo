#pragma once

#include <stdint.h>

#define MENU_ICON_WIDTH 128
#define MENU_ICON_HEIGHT 64
#define MENU_ICON_COUNT 5

/* About is a Settings text row, not a picture in this row.
   When an About carousel icon is supplied, add it here and raise MENU_ICON_COUNT. */
extern const uint8_t* const menu_icons[MENU_ICON_COUNT];
