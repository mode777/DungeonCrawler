#ifndef PGL_JSON_H
#define PGL_JSON_H

#include "common.h"

typedef struct PGLJSONParser_T PGLJSONParser;
typedef enum {
  PGL_JSON_UNDEFINED = 0,
	PGL_JSON_OBJECT = 1,
	PGL_JSON_ARRAY = 2,
	PGL_JSON_STRING = 3,
	PGL_JSON_NULL = 4,
	PGL_JSON_NUMBER = 5,
  PGL_JSON_BOOLEAN = 6
} PGLJSONToken;

PGLJSONParser* pglJsonCreateParser(const char* content);
void pglJsonDestroyParser(PGLJSONParser* parser);
bool pglJsonGetBoolVal(PGLJSONParser* parser);
double pglJsonGetDoubleVal(PGLJSONParser* parser);
char* pglJsonGetStringVal(PGLJSONParser* parser);
size_t pglJsonGetChildTokens(PGLJSONParser* parser);
PGLJSONToken pglJsonGetToken(PGLJSONParser* parser);
bool pglJsonNextToken(PGLJSONParser* parser);

#endif