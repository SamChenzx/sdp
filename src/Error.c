/*
 * File:   Error.c
 * Author: David Goodman
 *
 * Created on May 6, 2013, 1:31 AM
 */
#include <xc.h>
#include "Board.h"
#include "Error.h"

/***********************************************************************
 * PRIVATE DEFINITIONS                                                 *
 ***********************************************************************/

/***********************************************************************
 * PRIVATE VARIABLES                                                   *
 ***********************************************************************/

const char *ERROR_MESSAGE[] = {
    "None",
    "Unkown error.",
    "Never got reply from\nboat.",
    "GPS disconnected.",
    "GPS has no fix.", // GPs
    "Never got origin.", // boat didn't receive origin from CC
    "Never got station.", // boat doesn't have a station
    "Need altitude from\nboat.",
    "Lost connection with\nboat.",
    "Magnetometer failed.",
    "Barometer failed.",
    "Encoder failed.",
    "Accelerometer failed",
    "GPS failed init.",
    "Xbee failed.",
    "Tilt compass failed.",
    "I2C failed init.",
    "Navigation failed.",
    "In override mode."
};

/***********************************************************************
 * PRIVATE PROTOTYPES                                                  *
 ***********************************************************************/

/***********************************************************************
 * PUBLIC FUNCTIONS                                                    *
 ***********************************************************************/

/**********************************************************************
 * Function: getErrorMessage
 * @param Error code to retrieve the message for.
 * @return String representing error message.
 * @remark 
 **********************************************************************/
const char *getErrorMessage(error_t errorCode) {
    return ERROR_MESSAGE[errorCode];
}

