#include <string.h>
#include <stdio.h>
#include <stdint.h>

//C code to test 120bit RGB to YUV algorithm 

static const long hextable[] = {
   [0 ... 255] = -1, // bit aligned access into this table is considerably
   ['0'] = 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, // faster for most modern processors,
   ['A'] = 10, 11, 12, 13, 14, 15,       // for the space conscious, reduce to
   ['a'] = 10, 11, 12, 13, 14, 15        // signed char.
};

long hexdec(unsigned const char *hex)
{
   long ret = 0;

   while (*hex && ret >= 0)
   {
      ret = (ret << 4) | hextable[*hex++];
   }
   return ret;
}

int main(int argc, char *argv[])
{
        char str1[16]= {0};
        char str2[16]= {0};
        uint64_t  word1;
        uint64_t word2;
        uint16_t r[4]= {0};
        uint16_t g[4]= {0};
        uint16_t b[4]= {0};
        uint16_t y[4];
        uint16_t u[4];
        uint16_t v[4];

        if (argv[1] != NULL)
        {
                if (strlen(argv[1]) == 30)
                {
                        strncpy(str1, argv[1], 15);
                        strncpy(str2, &argv[1][15], 15);
                        printf("str1 %s str2 %s D %ld D %ld \n\n\n",str1, str2, hexdec(str1), hexdec(str2));
                        word1=hexdec(str1);
                        word2=hexdec(str2);
                        r[0] = (word1>>50) & 0x3FF;
                        g[0] = (word1>>40) & 0x3FF;
                        b[0] = (word1>>30) & 0x3FF;
                        r[1] = (word1>>20) & 0x3FF;
                        g[1] = (word1>>10) & 0x3FF;
                        b[1] = word1 & 0x3FF;

                        r[2] = (word2>>50) & 0x3FF;
                        g[2] = (word2>>40) & 0x3FF;
                        b[2] = (word2>>30) & 0x3FF;
                        r[3] = (word2>>20) & 0x3FF;
                        g[3] = (word2>>10) & 0x3FF;
                        b[3] = word2 & 0x3FF;


                        printf("%3d %3d %3d %3d %3d %3d\n%3d %3d %3d %3d %3d %3d\n",r[0], g[0], b[0], r[1], g[1], b[1], r[2], g[2], b[2], r[3], g[3], b[3]);
						printf("%3d %3d %3d %3d %3d %3d\n%3d %3d %3d %3d %3d %3d\n\n", (int)(r[0]*0.25), (int)(g[0]*0.25), (int)(b[0]*0.25), (int)(r[1]*0.25), (int)(g[1]*0.25), (int)(b[1]*0.25), (int)(r[2]*0.25), (int)(g[2]*0.25), (int)(b[2]*0.25), (int)(r[3]*0.25), (int)(g[3]*0.25), (int)(b[3]*0.25));
                        y[0] = ((77 * r[0]) + (150 * g[0]) + (29 * b[0])+ 128)>>10;
                        u[0] = (((-43 * r[0]) + (-84 * g[0]) + (127 * b[0])+ 128)>>10) + 128;
                        v[0] = (((127 * r[0]) + (-106 * g[0]) + (-21 * b[0])+ 128)>>10) + 128 ;

                        y[1] = ((77 * r[1]) + (150 * g[1]) + (29 * b[1])+ 128)>>10;
                        u[1] = (((-43 * r[1]) + (-84 * g[1]) + (127 * b[1]) + 128)>>10) + 128;
                        v[1] = (((127 * r[1]) + (-106 * g[1]) + (-21 * b[1])+ 128)>>10) + 128;

                        y[2] = ((77 * r[2]) + (150 * g[2]) + (29 * b[2])+ 128)>>10;
                        u[2] = (((-43 * r[2]) + (-84 * g[2]) + (127 * b[2])+ 128)>>10) + 128;
                        v[2] = (((127 * r[2]) + (-106 * g[2]) + (-21 * b[2])+ 128)>>10) + 128;

                        y[3] = ((77 * r[3]) + (150 * g[3]) + (29 * b[3])+ 128)>>10;
                        u[3] = (((-43 * r[3]) + (-84 * g[3]) + (127 * b[3])+ 128)>>10) + 128;
                        v[3] = (((127 * r[3]) + (-106 * g[3]) + (-21 * b[3])+ 128)>>10) + 128;

                        printf("%3d %3d %3d %3d \n%3d %3d %3d %3d\n\n",y[0], u[0], y[1], v[0], y[2], u[2], y[3], v[2]);
						
                        printf("%3d %3d %3d %3d \n%3d %3d %3d %3d\n",y[0], (u[0]+u[1])/2, y[1], (v[0]+v[1])/2, y[2], (u[2]+u[3])/2, y[3], (v[2] + v[3])/2);
						
						printf("%02x%02x%02x%02x%02x%02x%02x%02x\n", y[0], u[0], y[1], v[0], y[2], u[2], y[3], v[2]); 
                }
                else
                {
                        printf("Invalid Argument\n");
                }
        }
        else
        {
                printf("Invalid Argument\n");
        }
}

