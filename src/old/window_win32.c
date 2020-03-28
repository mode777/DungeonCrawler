#include "window.h"
#include <windows.h>

LRESULT CALLBACK wndProc(HWND hwnd, unsigned int msg, WPARAM wParam, LPARAM lParam)
{
	switch (msg)
	{
		case WM_CLOSE : {
			//quit = 1;
			PostQuitMessage(0);
			return 0;
		}
		case WM_DESTROY: {
			DestroyWindow(hwnd);
			return 0;
		}
		case WM_SIZE: {
			//winWidth = LOWORD(lParam);
			//winHeight = HIWORD(lParam);
			return 0;
		}
	}

	return (DefWindowProc(hwnd, msg, wParam, lParam));
}

inline void pglDestroyWindow(PGLHandle handle){
	DestroyWindow(handle);
}

PGLHandle pglCreateWindow(int width, int height) {
	HINSTANCE hInstance = GetModuleHandle(NULL);
	WNDCLASSEX wcex;
	
	wcex.cbSize = sizeof(WNDCLASSEX);
	wcex.style = CS_HREDRAW | CS_VREDRAW | CS_OWNDC;
	wcex.lpfnWndProc = &DefWindowProc;
	wcex.cbClsExtra = 0;
	wcex.cbWndExtra = 0;
	wcex.hInstance = hInstance;
	wcex.hIcon = NULL;
	wcex.hCursor = LoadCursor(NULL, IDC_ARROW);
	wcex.hbrBackground = 0;
	wcex.lpszMenuName = NULL;
	wcex.lpszClassName = "eglsamplewnd";
	wcex.hIconSm = NULL;
	wcex.lpfnWndProc = wndProc;

	RegisterClassEx(&wcex);
	RECT rect = { 0, 0, width, height };
	int style = WS_BORDER | WS_CAPTION | WS_SYSMENU | WS_THICKFRAME;
	AdjustWindowRect(&rect, style, FALSE);

	HWND hwnd = CreateWindow("eglsamplewnd", "EGL OpenGL ES 2.0", style, CW_USEDEFAULT, CW_USEDEFAULT, rect.right - rect.left, rect.bottom - rect.top, NULL, NULL, GetModuleHandle(NULL), NULL);
	ShowWindow(hwnd, SW_SHOW);

	return (PGLHandle)hwnd;
}

int pglPumpEvents(){
	MSG sMessage;

	if(PeekMessage(&sMessage, NULL, 0, 0, PM_REMOVE)) {
			if(sMessage.message == WM_QUIT) {
					return 0;
			} else {
					TranslateMessage(&sMessage);
					DispatchMessage(&sMessage);
			}
	}

	return 1;
}