#ifndef PGL_WREN_H
#define PGL_WREN_H

#include "common.h"

void pglInitWren();
void pglRunWrenFile(const char* module, const char* file);
void pglCallWrenUpdate(double delta);
void pglCallWrenInit();
void pglCallWrenLoad();

#endif