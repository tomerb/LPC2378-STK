#include <stdint.h>

#include "lpc2378.h"
#include "init.h"
#include "print.h"

extern void initGpioPorts(void);
extern void turnLedOn(void);
extern void turnLedOff(void);
extern uint32_t getPressedButton(void);

#define BUT1   1
#define BUT2   2
#define CENTER 3
#define LEFT   4
#define RIGHT  5
#define UP     6
#define DOWN   7

static int isButtonPressed(void)
{
        const uint32_t pressed_val = getPressedButton();
        switch (pressed_val)
        {
        case BUT1:
            printString("Button pressed: BUT1\n");
            break;
        case BUT2:
            printString("Button pressed: BUT2\n");
            break;
        case CENTER:
            printString("Button pressed: CENTER\n");
            break;
        case LEFT:
            printString("Button pressed: LEFT\n");
            break;
        case RIGHT:
            printString("Button pressed: RIGHT\n");
            break;
        case UP:
            printString("Button pressed: UP\n");
            break;
        case DOWN:
            printString("Button pressed: DOWN\n");
            break;
        default:
            return 0;
        }

        return 1;
}

int main(void)
{
    uint32_t p;

    initHardware();

    printString("\033[2J"); /* Clear entire screen */

    initGpioPorts();

    while (1)
    {
        if (isButtonPressed())
            turnLedOn();
        else
            turnLedOff();

        for (p = 0; p < 0x100000; p++ );        // wait
    }

    return 0;
}
