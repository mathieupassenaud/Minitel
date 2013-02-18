#include <windows.h>
#include <stdio.h>


DCB dcb;
HANDLE hCom;

char *pcCommPort = "COM1";

void writeChar(char c);
int initSerialPort();
char* readLine();
   
int main(int argc, char *argv[]){
    initSerialPort();
    char string[] = "This is a string written to output";
    int i = 0;
    while(string[i] != '\0'){
      writeChar(string[i]);
      i++;
    }
    
    char* inputLine = readLine();
    printf("%s", inputLine);
    while(1);
}

char* readLine(){
    char* inputLine;
    char read;
    
    DWORD iBytesRead;
    DWORD iBytesToRead = 1;
    int i = 0;
    while(read != '\n'){
        ReadFile(hCom, &read, iBytesToRead , &iBytesRead, NULL);
        inputLine[i] = read;
        i++;
        #make echo to the terminal
        printf("read char %c", read);
        writeChar(read);
    }
    return inputLine;
}

void writeChar(char c){
   DWORD iBytesWritten;
   WriteFile(hCom, &c, 1, &iBytesWritten,NULL);
}

int initSerialPort(){
   BOOL fSuccess;
   hCom = CreateFile( pcCommPort,
                    GENERIC_READ | GENERIC_WRITE,
                    0,    // must be opened with exclusive-access
                    NULL, // no security attributes
                    OPEN_EXISTING, // must use OPEN_EXISTING
                    0,    // not overlapped I/O
                    NULL  // hTemplate must be NULL for comm devices
                    );

   if (hCom == INVALID_HANDLE_VALUE) 
   {
       // Handle the error.
       printf ("CreateFile failed with error %d.\n", GetLastError());
       return (1);
   }

   // Build on the current configuration, and skip setting the size
   // of the input and output buffers with SetupComm.

   fSuccess = GetCommState(hCom, &dcb);

   if (!fSuccess) 
   {
      // Handle the error.
      printf ("GetCommState failed with error %d.\n", GetLastError());
      return (2);
   }

   // Fill in DCB: 4800 bps, 7 data bits, even parity, and 1 stop bit.

   dcb.BaudRate = CBR_4800;     // set the baud rate
   dcb.ByteSize = 7;             // data size, xmit, and rcv
   dcb.Parity = EVENPARITY;        // even parity bit
   dcb.StopBits = ONESTOPBIT;    // one stop bit

   fSuccess = SetCommState(hCom, &dcb);

   if (!fSuccess) 
   {
      // Handle the error.
      printf ("SetCommState failed with error %d.\n", GetLastError());
      return (3);
   }
   
   printf ("Serial port %s successfully reconfigured.\n", pcCommPort);
   return (0);   
}
