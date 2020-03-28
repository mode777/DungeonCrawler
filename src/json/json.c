#include <modules/pgl_json.h>
#include <jsmn/jsmn.h>

#define PGL_JSON_START_TOKENS 1024

struct PGLJSONParser_T {
  const char * content;
  jsmntok_t* tokens;
  size_t num_tokens;
  int index;
  jsmntok_t token;
};

PGLJSONParser* pglJsonCreateParser(const char* content){
  jsmn_parser parser;
  jsmn_init(&parser);

  size_t num_tokens = PGL_JSON_START_TOKENS;
  jsmntok_t* tokens = malloc(num_tokens * sizeof(jsmntok_t));
  int tokensParsed;
  size_t contentLength = strlen(content);

  while((tokensParsed = jsmn_parse(&parser, content, contentLength, tokens, num_tokens)) == JSMN_ERROR_NOMEM){
    num_tokens *= 2;
    pglLog(PGL_MODULE_JSON, PGL_LOG_INFO, "Allocating more tokens %i", num_tokens);
    tokens = realloc(tokens, num_tokens * sizeof(jsmntok_t));
  }

  if(tokensParsed == JSMN_ERROR_INVAL || tokensParsed == JSMN_ERROR_PART){
    pglLog(PGL_MODULE_JSON, PGL_LOG_ERROR, "Invalid JSON input");
    return NULL;
  }

  PGLJSONParser* inst = calloc(1, sizeof(PGLJSONParser));
  inst->content = content;
  inst->num_tokens = tokensParsed;
  inst->index = -1;
  inst->tokens = tokens;
  
  return inst;
}

void pglJsonDestroyParser(PGLJSONParser* parser){
  free(parser->tokens);
  free(parser);
}

bool pglJsonGetBoolVal(PGLJSONParser* parser){
  return parser->content[parser->token.start] == 't' 
    ? true
    : false; 
}

double pglJsonGetDoubleVal(PGLJSONParser* parser){
  return strtod(&parser->content[parser->token.start], NULL);
}

char* pglJsonGetStringVal(PGLJSONParser* parser){
  int start = parser->token.start;
  int size = parser->token.end - start;

  char * buffer = malloc(size + 1);

  strncpy(buffer, (parser->content + start), size);

  buffer[size] = 0;

  return buffer;
}

size_t pglJsonGetChildTokens(PGLJSONParser* parser) {
  return parser->token.size;
}

PGLJSONToken pglJsonGetToken(PGLJSONParser* parser) {
  switch (parser->token.type) {
    case JSMN_UNDEFINED: return PGL_JSON_UNDEFINED;
    case JSMN_OBJECT: return PGL_JSON_OBJECT;
    case JSMN_ARRAY: return PGL_JSON_ARRAY;
    case JSMN_STRING: return PGL_JSON_STRING;
    case JSMN_PRIMITIVE: {
      switch(parser->content[parser->token.start]){
        case 't':
        case 'f': return PGL_JSON_BOOLEAN;
        case 'n': return PGL_JSON_NULL;
        case '-':
        case '0':
        case '1':
        case '2':
        case '3':
        case '4':
        case '5':
        case '6':
        case '7':
        case '8':
        case '9': return PGL_JSON_NUMBER;
        default: return PGL_JSON_UNDEFINED;
      }
    }
    default: return PGL_JSON_UNDEFINED;
  }
}

bool pglJsonNextToken(PGLJSONParser* parser){
  if(parser->index < (int)parser->num_tokens){
    parser->token = parser->tokens[parser->index++];
    return true;
  }
  return false;
}