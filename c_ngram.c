#include<stdio.h>
#include <string.h>
#include <stdlib.h>


extern int n_gram(char* , int , char* , int , int ) ;		//declaration of assembly subroutine



int main(){
	
	FILE* filePointer;
	int bufferLength = 300;
	char buffer[bufferLength];
	char buffer_total[3][bufferLength];

	filePointer = fopen("input_tab.txt", "r");

	// get every line from file and parse them with delimiter of space
	while(fgets(buffer, bufferLength, filePointer)) {
		char * parsed_character = strtok (buffer,"\t\n");
		int counter = 0;
		while (parsed_character != NULL){

			strcpy(buffer_total[counter], parsed_character);		//copy the line into a buffer

			parsed_character = strtok (NULL, "\t\n");
						
			counter++;
			if(counter==3){
				//printf ("%s %s %s", buffer_total[0], buffer_total[1], buffer_total[2]);
				char* str_1;
				int size_1;
				char* str_2;
				int size_2;
				int n;

				str_1 = buffer_total[1];
				size_1 = strlen(str_1);
				str_2 = buffer_total[2];
				size_2 = strlen(str_2);			
				n = atoi(buffer_total[0]);		// n is the first item in the line

				int result = n_gram(str_1 , size_1 , str_2 , size_2 , n );
				
				printf("similarity between %s-%s is:  %d\n",str_1, str_2, result );


				counter = 0;
			}
				
		}
	}

	fclose(filePointer);
}


































































