#include <modules/gl.h>
#include <cglm/cglm.h>

static const char *loadFile(const char *file)
{
   char *source = NULL;
   FILE *fp = fopen(file, "r");
   if (fp != NULL)
   {
      /* Go to the end of the file. */
      if (fseek(fp, 0L, SEEK_END) == 0)
      {
         /* Get the size of the file. */
         long bufsize = ftell(fp);
         if (bufsize == -1)
         { /* Error */
         }

         /* Allocate our buffer to that size. */
         source = malloc(sizeof(char) * (bufsize + 1));

         /* Go back to the start of the file. */
         if (fseek(fp, 0L, SEEK_SET) != 0)
         { /* Error */
         }

         /* Read the entire file into memory. */
         size_t newLen = fread(source, sizeof(char), bufsize, fp);
         if (ferror(fp) != 0)
         {
            fputs("Error reading file", stderr);
         }
         else
         {
            source[newLen++] = '\0'; /* Just to be safe. */
         }
      }
      fclose(fp);
   }
   else
   {
      pglLog(PGL_MODULE_GL, PGL_LOG_ERROR, "File not found: %s", file);
   }
   return source;
}

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

GLuint pglLoadProgram(const char *vertShaderSrc, const char *fragShaderSrc)
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

GLuint pglLoadProgramFile(const char *vertShaderFile, const char *fragShaderFile)
{
   const char *vSrc = loadFile(vertShaderFile);
   const char *fSrc = loadFile(fragShaderFile);

   GLuint p = pglLoadProgram(vSrc, fSrc);

   free((void *)vSrc);
   free((void *)fSrc);

   return p;
}
