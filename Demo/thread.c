#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>

struct member  
{  
    int a;  
    char *s;  
};  

void *mythread1(void *ptr)  
{  
    char *p = (char *)ptr;
    
    for (;;)
    {
        printf("This is the 1st pthread!\n"); 
        /* 传参 */
        printf("The 1st pthread's paramater is : %s!\n", p); 
        /* 获取并打印线程id */
        printf("The 1st pthread's id is %u \n", (unsigned int)pthread_self());
        printf("\n");
        
        sleep(5);
    }
}  
  
void *mythread2(void)  
{  
    int i;  
    
    for(i = 0; i < 3; i++)  
    {  
        printf("This is the 2st pthread!\n"); 
        sleep(1);  
    } 
    printf("\n");
    /* 1、该线程在这里运行完，系统是否会自动回收资源?需要手动释放吗? */
} 

void *create(void *arg)  
{  
    struct member *pTmp;  
    
    pTmp = (struct member *)arg;  
    printf("member->a = %d\n", pTmp->a);  
    printf("member->s = %s\n", pTmp->s);  
    printf("\n");
    
    return (void *)0;  
}  



int main(int argc, char *argv[])
{
    int i = 0;  
    int ret = 0; 
    pthread_t id1, id2, id3;  
    
    char *p = "pass parameter!";  //"传递参数";
    struct member *pMem;  
    pMem = (struct member *)malloc(sizeof(struct member));  
    pMem->a = 1;  
    pMem->s = "hello world!";

    /* pthread_create只能传递一个参数，如果想要传递多个参数，可以用传递一个结构体指针过去 */
    ret = pthread_create(&id1, NULL, (void *)mythread1, (void *)p);  
    if(ret)  
    {  
        printf("Create pthread error!\n");  
        return 1;  
    }  
  
    ret = pthread_create(&id2, NULL, (void *)mythread2, NULL);  
    if(ret)  
    {  
        printf("Create pthread error!\n");  
        return 1;  
    }  

    ret = pthread_create(&id3, NULL, (void *)create, (void *)pMem);  
    if(ret)  
    {  
        printf("Create pthread error!\n");  
        return 1;  
    }  


    /*
        pthread_join的作用:
        1、第一个功能就是会阻塞等待子线程执行结束；
        2、另一个功能就是回收线程结束后的资源
    */
    pthread_join(id2,NULL);         /* 线程2会退出，退出后，运行到这儿，回收资源 */
    printf("Over 2st pthread\n");   /* 会打印 */
    
    pthread_join(id1,NULL);         /* 线程1由于死循环，因此不会退出 呈现会阻塞在这里 */
    printf("Over 1st pthread\n");   /* 不会运行到这 */

    pthread_join(id3,NULL);
    printf("Over 3st pthread\n");   /* 不会运行到这 */
    
    return 0;
}

