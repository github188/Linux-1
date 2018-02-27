#include <stdio.h>
#include <strings.h>
#include <pthread.h>
#include <sys/types.h> 
#include <sys/socket.h>
#include <netinet/in.h>
#include <signal.h>
#include <errno.h> 


#define LISTENQ     5
#define RECV_MAX    4096



/*
    pthread_kill的返回值：
    成功（0） 
    线程不存在（ESRCH） 
    信号不合法（EINVAL）
*/
void test_pthread(pthread_t tid) 
{
    int pthread_kill_err;
    
    pthread_kill_err = pthread_kill(tid, 0);

    if(pthread_kill_err == ESRCH)
    {
        printf("a ID为0x%x的线程不存在或者已经退出!\n", (unsigned int)tid);
    }
    else if(pthread_kill_err == EINVAL)
    {
        printf("b 发送信号非法!\n");
    }  
    else
    {
        printf("c ID为0x%x的线程目前仍然存活!\n", (unsigned int)tid);
    }   
}



/* 
    长连接
    1、对方主动关闭连接时，线程销毁
    2、select超时时，线程销毁
    否则，只要accept了，创建了线程，(不超时，client不关闭)，这个连接会一直保持下去
*/
static void* processAtmRequestForHik(void *arg)
{
    char buff[RECV_MAX];
    fd_set rset;
    struct timeval select_timeout;
    struct linger tcpLinger;
    int connFd = *(int *)arg;
    pthread_t tid;
    int result;
    int num;

    tid = pthread_self();
    printf("%u: is the pthread's id\n", (unsigned int)tid);
    
    for (;;) 
    {
        FD_ZERO(&rset);
        FD_SET(connFd, &rset);
        select_timeout.tv_sec = 5;
        select_timeout.tv_usec = 0;
        if ((result = select(connFd+1, &rset, NULL, NULL, &select_timeout)) > 0)
        {
            bzero(buff, sizeof(buff));
            printf("%u: clear buff!\n", (unsigned int)tid);
            
            if (FD_ISSET(connFd, &rset))
            {
                if ((num = read(connFd, buff, RECV_MAX)) <= 0)
                {
                    if (num == 0)
                    {
                        printf("%u: client closed the fd!\n", (unsigned int)tid);
                    }
                    else
                    {
                        printf("%u: read error!\n", (unsigned int)tid);
                    }
                    goto errExit;
                }
                printf("%u: received is %s\n", (unsigned int)tid, buff);
            }
        }
        else
        {
            if (result == 0)
            {
                printf("%u: select timeout!\n", (unsigned int)tid);
            }
            else
            {
                printf("%u: select error!\n", (unsigned int)tid);
            }


            tcpLinger.l_onoff = 1;
            tcpLinger.l_linger = 0;
            setsockopt(connFd, SOL_SOCKET, SO_LINGER, (char*)&tcpLinger, sizeof(struct linger));
            printf("%u: disconnect request!\n", (unsigned int)tid);
            goto errExit;
        }
    }

errExit:

    close(connFd);
    
    pthread_detach(pthread_self());
        
    return ;
}


int main(int argc, char *argv[])
{
    pthread_t tid;
    int sockFd, connFd;
    struct sockaddr_in serverAddr, clientAddr;
    int sockAddrSize;
    int addreuse = 1;
    struct linger tcpLinger;
    pthread_attr_t attr;

    sockFd = socket(AF_INET, SOCK_STREAM, 0);
    if (sockFd < 0)
    {
        printf("atmNetRecv, create socket failed.\n");
        return ;
    }

    /*
        SO_REUSEADDR允许一个server程序listen监听并bind到一个端口,
        即使这个端口已经被一个正在运行的连接使用了.
    */
    if (setsockopt(sockFd, SOL_SOCKET, SO_REUSEADDR, (char*)&addreuse, sizeof(int)) < 0)
    {
        printf("atmNetRecv, setsockopt failed.\n");
        return ;
    }

    sockAddrSize = sizeof(struct sockaddr_in);
    bzero((char *)&serverAddr, sockAddrSize);   
    serverAddr.sin_family = AF_INET;
    serverAddr.sin_port = htons(60000);
    serverAddr.sin_addr.s_addr= htonl(INADDR_ANY);

    if (bind(sockFd, (struct sockaddr *) &serverAddr, sizeof(struct sockaddr_in)) < 0)
    {
        printf("atmNetRecv, bind failed.\n");
    }

    if (listen(sockFd, LISTENQ) < 0)
    {
        printf("atmNetRecv, listen failed.\n");
    }
    
    for (;;) 
    {
        if ((connFd = accept(sockFd, (struct sockaddr *)&clientAddr, (socklen_t*)&sockAddrSize)) < 0)
        {
            printf("atmNetRecv, accept failed.\n");
            continue;
        }

printf("\naccespt ok !\n");

        pthread_attr_init(&attr);
        pthread_attr_setdetachstate(&attr, PTHREAD_CREATE_DETACHED);
        if (pthread_create(&tid, &attr, processAtmRequestForHik, (void *)&connFd) != 0)
        {
            printf("atmNetRecv, pthread_create failed.\n");
            close(connFd);
            connFd = -1;

            /*
                在默认情况下,当调用close关闭socket的使用,close会立即返回,但是,如果
                send buffer中还有数据,系统会试着先把send buffer中的数据发送出去,
                然后close才返回.SO_LINGER选项则是用来修改这种默认操作的.
                
                设置 l_onoff为非0，l_linger为0，则套接口关闭时TCP夭折连接，TCP将丢弃
                保留在套接口发送缓冲区中的任何数据并发送一个RST给对方，而不是通常的四
                分组终止序列，这避免了TIME_WAIT状态；
            */
            /* zj: 为什么放在close后面? */
            tcpLinger.l_onoff = 1;
            tcpLinger.l_linger = 0;
            setsockopt(connFd, SOL_SOCKET, SO_LINGER, (char*)&tcpLinger, sizeof(struct linger));
            continue;
        }
        //pthread_attr_destroy(&attr);
        
        //sleep(5);
        test_pthread(tid);
    }
    close(sockFd);
    sockFd = -1;
    return ;
}


