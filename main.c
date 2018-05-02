#include <stdio.h>
#include <stdlib.h>
/* change to whatever you like: */
#define MAX_PHYSICAL_MEMORY 4096
//static long M[MAX_PHYSICAL_MEMORY] = {
        //...SIC program encoding goes here...
//};
int main()
{
    int n = 0;
    long buff[MAX_PHYSICAL_MEMORY];
    int res = 0;
    while ( (res = scanf("%lu", &buff[n])) != -1){
        n++;
    }

    long* M = calloc(n, 8); // n quadwords

    for (int j = 0; j < n; j++){
        M[j] = buff[j];
    }
    
    int i = 0;
    
    while (M[i] || M[i + 1] || M[i + 2]){
        printf( "M[%d]: %lu M[M[%d]]: %lu\n", i, M[i], i, M[M[i]] );
        printf( "M[%d]: %lu M[M[%d]]: %lu\n", i+1, M[i+1], i+1, M[M[i+1]] );
        printf( "M[%d]: %lu M[M[%d]]: %lu\n", i+2, M[i+2], i+2, M[M[i+2]] );
        if ((M[M[i]] -= M[M[i + 1]]) < 0){
             i = M[i + 2];
        }
        else{
             i += 3;
        }
    }

    for (i = 0; i < n; ++i) {
        printf("%lu ", M[i]);
    }
    printf("\n");
    return 0;
}