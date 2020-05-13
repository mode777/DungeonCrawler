#include <modules/gl.h>
#include <cglm/cglm.h>

static GLuint loadShader(GLenum type, const char *shaderSrc)
{
   GLuint shader;
   GLint compiled;

   // Create the shader object
   shader = glCreateShader(type);

   if (shader == 0)
      return 0;

   // Load the shader source
   glShaderSource(shader, 1, &shaderSrc, NULL);

   // Compile the shader
   glCompileShader(shader);

   // Check the compile status
   glGetShaderiv(shader, GL_COMPILE_STATUS, &compiled);

   if (!compiled)
   {
      GLint infoLen = 0;

      glGetShaderiv(shader, GL_INFO_LOG_LENGTH, &infoLen);

      if (infoLen > 1)
      {
         char *infoLog = (char *)malloc(sizeof(char) * infoLen);

         glGetShaderInfoLog(shader, infoLen, NULL, infoLog);
         pglLog(PGL_MODULE_GL, PGL_LOG_ERROR, "Error compiling shader:\n%s", infoLog);

         free(infoLog);
      }

      glDeleteShader(shader);
      return 0;
   }

   return shader;
}

static GLuint loadProgram(const char *vertShaderSrc, const char *fragShaderSrc)
{
   GLuint vertexShader;
   GLuint fragmentShader;
   GLuint programObject;
   GLint linked;

   // Load the vertex/fragment shaders
   vertexShader = loadShader(GL_VERTEX_SHADER, vertShaderSrc);
   if (vertexShader == 0)
      return 0;

   fragmentShader = loadShader(GL_FRAGMENT_SHADER, fragShaderSrc);
   if (fragmentShader == 0)
   {
      glDeleteShader(vertexShader);
      return 0;
   }

   // Create the program object
   programObject = glCreateProgram();

   if (programObject == 0)
      return 0;

   glAttachShader(programObject, vertexShader);
   glAttachShader(programObject, fragmentShader);
   
   // Link the program
   glLinkProgram(programObject);

   // Check the link status
   glGetProgramiv(programObject, GL_LINK_STATUS, &linked);

   if (!linked)
   {
      GLint infoLen = 0;

      glGetProgramiv(programObject, GL_INFO_LOG_LENGTH, &infoLen);

      if (infoLen > 1)
      {
         char *infoLog = (char *)malloc(sizeof(char) * infoLen);

         glGetProgramInfoLog(programObject, infoLen, NULL, infoLog);
         pglLog(PGL_MODULE_GL, PGL_LOG_ERROR, "Error linking program:\n%s", infoLog);

         free(infoLog);
      }

      glDeleteProgram(programObject);
      return 0;
   }

   // Free up no longer needed shader resources
   glDeleteShader(vertexShader);
   glDeleteShader(fragmentShader);

   return programObject;
}

PGLProgram* pglProgramCreate(const char *vertShaderSrc, const char *fragShaderSrc){
   
   GLuint program = loadProgram(vertShaderSrc, fragShaderSrc);
   
   if(program == NULL)
      return NULL;

   PGLProgram* prog = calloc(1, sizeof(PGLProgram));
   prog->program = program;

   for (int i = 0; i < PGL_MAX_ATTRIBUTES; i++)
   {
      prog->attributes[i] = -1;
   }

   for (int i = 0; i < PGL_MAX_UNIFORMS; i++)
   {
      prog->uniforms[i] = -1;
   } 

   return prog;
}

void pglProgramDelete(PGLProgram* p){
   glDeleteProgram(p->program);
   free(p);
}