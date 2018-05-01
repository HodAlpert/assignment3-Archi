#include <stdio.h>
#include <stdlib.h>
/* change to whatever you like: */
#define MAX_PHYSICAL_MEMORY 4096
static long M[MAX_PHYSICAL_MEMORY] = {
        //...SIC program encoding goes here...
};
int main()
{
    int i = 0;
    char *format;
    while (M[i] || M[i + 1] || M[i + 2])
        if ((M[M[i]] -= M[M[i + 1]]) < 0) i = M[i + 2];
        else i += 3;
    for (i = 0; i < MAX_PHYSICAL_MEMORY; ++i) {
        printf("%d ", M[i]);
    }
    printf("\n");
    return 0;
}