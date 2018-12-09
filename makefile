

*、?、[…]

 

* 

代表0到无穷多个任意字符；

“*.c”表示所有以后缀为c的文件。如果我们的文件名中有通配符，如：“*”，那么可以用转义字符“\”，如“\*”来表示真实的“*”字符，而不是任意长度的字符串。

 

?      

代表一定有一个任意字符

[]     

同样代表一定有一个在中括号内的字符（非任意字符）。例如[abcd]代表一定有一个字符，可能是a，b，c，d这四个中任何一个。

 

%    

“%”的意思是匹配零或若干字符

@

取消回显
（演示）

 

=                  是最基本的赋值

:=                 是覆盖之前的值

?=                 是如果没有被赋值过就赋予等号后面的值

+=                是添加等号后面的值

$@                --代表目标文件(target)

$^                  --代表所有的依赖文件(components)

$<                 --代表第一个依赖文件(components中最左边的那个)。

 

 

make的工作方式

Makefile默认执行第一个目标。所以像clean这种目标千万不要写在最前面。

 

GNU的make工作时的执行步骤入下：（想来其它的make也是类似）

1、读入所有的Makefile。

2、读入被include的其它Makefile。

3、初始化文件中的变量。

4、推导隐晦规则，并分析所有规则。

5、为所有的目标文件创建依赖关系链。

6、根据依赖关系，决定哪些目标要重新生成。

7、执行生成命令。

 

1-5步为第一个阶段，6-7为第二个阶段。第一个阶段中，如果定义的变量被使用了，那么，make会把其展开在使用的位置。但make并不会完全马上展开，make使用的是拖延战术，如果变量出现在依赖关系的规则中，那么仅当这条依赖被决定要使用了，变量才会在其内部展开。

 

Makefile中的三个通配符

*、?、[…]

 

* 代表0到无穷多个任意字符；

“*.c”表示所有以后缀为c的文件。如果我们的文件名中有通配符，如：“*”，那么可以用转义字符“\”，如“\*”来表示真实的“*”字符，而不是任意长度的字符串。



 

?      代表一定有一个任意字符

[]     同样代表一定有一个在中括号内的字符（非任意字符）。例如[abcd]代表一定有一个字符，可能是a，b，c，d这四个中任何一个。

 

波浪号（“~”）字符在文件名中也有比较特殊的用途。如果是“~/test”，这就表示当前用户的$HOME目录下的test目录。而“~hchen/test”则表示用户hchen的宿主目录下的test目录。

zhajin@Cpl-Backend-Platform-2:~/data/work/4HDD-TVI-ATM_v3.4.31_ICBC/Baseline/APPS$
cd ~

zhajin@Cpl-Backend-Platform-2:~$ 

zhajin@Cpl-Backend-Platform-2:~$ cd -

/back-end-team/zhajin/data/work/4HDD-TVI-ATM_v3.4.31_ICBC/Baseline/APPS

zhajin@Cpl-Backend-Platform-2:~/data/work/4HDD-TVI-ATM_v3.4.31_ICBC/Baseline/APPS$

 

 

 

 

变量赋值 =与:=

#测试二 :

ha1:=1

ha2:=$(ha1)

haha:

       @#结果打印的是3 表明变量作用域是全覆盖的 无论在前还是在后

       @echo
$(ha2)

ha2:=3

#######

如果最后加上：ha2+=$(ha2)

那么打印的是：3 3 

 

在定义变量的值时，我们可以使用其它变量来构造变量的值，在Makefile中有两种方式来在用变量定义变量的值。

先看第一种方式，也就是简单的使用“=”号，在“=”左侧是变量，右侧是变量的值，右侧变量的值可以定义在文件的任何一处，也就是说，右侧中的变量不一定非要是已定义好的值，其也可以使用后面定义的值。如：

foo = $(bar)

bar = $(ugh)

ugh = Huh?

all:

echo $(foo)

我们执行“make all”将会打出变量$(foo)的值是“Huh?”（ $(foo)的值是$(bar)，$(bar)的值是$(ugh)，$(ugh)的值是“Huh?”）可见，变量是可以使用后面的变量来定义的。

这个功能有好的地方，也有不好的地方，好的地方是，我们可以把变量的真实值推到后面来定义，如：

CFLAGS = $(include_dirs) -O

include_dirs = -Ifoo -Ibar

当“CFLAGS”在命令中被展开时，会是“-Ifoo -Ibar -O”。但这种形式也有不好的地方，那就是递归定义，如：

CFLAGS = $(CFLAGS) -O

或：

A = $(B)

B = $(A)

这中变量定义方式会让make陷入无限的变量展开过程中去。

 

了避免上面的这种方法，我们可以使用make中的另一种用变量来定义变量的方法。这种方法使用的是“:=”操作符，如：

x := foo

y := $(x) bar

x := later

其等价于：

y := foo bar

x := later

值得一提的是，这种方法，前面的变量不能使用后面的变量，只能使用前面已定义好了的变量。如果是这样：

y := $(x) bar

x := foo

那么，y的值是“bar”，而不是“foo bar”。

 

变量追加值 +=

我们可以使用“+=”操作符给变量追加值，如：

objects = main.o foo.o bar.o utils.o

objects +=
another.o

于是，我们的$(objects)值变成：“main.o foo.o bar.o utils.o another.o”（another.o被追加进去了）

使用“+=”操作符，可以模拟为下面的这种例子：

objects = main.o foo.o bar.o utils.o

objects := $(objects) another.o

所不同的是，用“+=”更为简洁。

如果变量之前没有定义过，那么，“+=”会自动变成“=”，如果前面有变量定义，那么“+=”会继承于前次操作的赋值符。如果前一次的是“:=”，那么“+=”会以“:=”作为其赋值符，如：

variable := value

variable += more

等价于：

variable := value

variable := $(variable) more

但如果是这种情况：

variable = value

variable += more

由于前次的赋值符是“=”，所以“+=”也会以“=”来做为赋值，那么岂不会发生变量的递补归定义，这是很不好的，所以make会自动为我们解决这个问题，我们不必担心这个问题。

 

 

变量

环境变量

MAKECMDGOALS

有一个make的环境变量叫“MAKECMDGOALS”，这个变量中会存放你所指定的终极目标的列表，如果在命令行上，你没有指定目标，那么，这个变量是空值。这个变量可以让你使用在一些比较特殊的情形下。比如下面的例子：

sources = foo.c bar.c

ifneq ( $(MAKECMDGOALS),clean)

include $(sources:.c=.d)

endif

基于上面的这个例子，只要我们输入的命令不是“make clean”，那么makefile会自动包含“foo.d”和“bar.d”这两个makefile。

 

例如，Makefile内容如下：

do:

       @echo
$(MAKECMDGOALS)

执行make do，会打印do出来。

 

 

 

自动化变量

在makefile中，存在系统默认的自动化变量

$@                --代表目标文件(target)

$^                  --代表所有的依赖文件(components)

$<                 --代表第一个依赖文件(components中最左边的那个)。

 

 

变量值的替换

$(var:a=b)

我们可以替换变量中的共有的部分，其格式是“$(var:a=b)”或是“${var:a=b}”，其意思是，把变量“var”中所有以“a”字串“结尾”的“a”替换成“b”字串。这里的“结尾”意思是“空格”或是“结束符”。

还是看一个示例吧：

foo := a.o b.o c.o

bar := $(foo:.o=.c)

这个示例中，我们先定义了一个“$(foo)”变量，而第二行的意思是把“$(foo)”中所有以“.o”字串“结尾”全部替换成“.c”，所以我们的“$(bar)”的值就是“a.c b.c c.c”。

 

$(var:%.c=%.o)

另外一种变量替换的技术是以“静态模式”（参见前面章节）定义的，如：

foo := a.o b.o c.o

bar := $(foo:%.o=%.c)

这依赖于被替换字串中的有相同的模式，模式中必须包含一个“%”字符，这个例子同样让$(bar)变量的值为“a.c b.c
c.c”。

 

把变量的值再当成变量

x = y

y = z

a := $($(x))

在这个例子中，$(x)的值是“y”，所以$($(x))就是$(y)，于是$(a)的值就是“z”。（注意，是“x=y”，而不是“x=$(y)”）

我们还可以使用更多的层次：

x = y

y = z

z = u

a := $($($(x)))

这里的$(a)的值是“u”，相关的推导留给读者自己去做吧。

 

让我们再复杂一点，使用上“在变量定义中使用变量”的第一个方式，来看一个例子：

x = $(y)

y = z

z = Hello

a := $($(x))

这里的$($(x))被替换成了$($(y))，因为$(y)值是“z”，所以，最终结果是：a:=$(z)，也就是“Hello”。

 

 

 

指定文件的搜索路径

特殊变量VPATH

make需要去寻找文件的依赖关系时，只会在当前目录（优先）中去寻找，如果找不到，就会到VPATH（特殊变量）指定的路径中去寻找文件。

例如：

VPATH = src:../headers

上面的的定义指定两个目录，“src”和“../headers”，make会按照这个顺序进行搜索。目录由“冒号”分隔。（当然，当前目录永远是最高优先搜索的地方）

 

关键字vpath

这不是变量，这是一个make的关键。

它更为灵活，可以指定不同的文件在不同的搜索目录中。它的使用方法有三种：

1、vpath <pattern> <directories>

为符合模式<pattern>的文件指定搜索目录<directories>。

2、vpath <pattern>

清除符合模式<pattern>的文件的搜索目录。

3、vpath

清除所有已被设置好了的文件搜索目录。

 

vapth使用方法中的<pattern>需要包含“%”字符。“%”的意思是匹配零或若干字符，例如，“%.h”表示所有以“.h”结尾的文件。<pattern>指定了要搜索的文件集，而<directories>则指定了<pattern>的文件集的搜索的目录。例如：

vpath %.h ../headers

该语句表示，要求make在“../headers”目录下搜索所有以“.h”结尾的文件。（如果某文件在当前目录没有找到的话）

 

 

 

 

 

 

生成动态库

生成静态库

生成可执行文件

 

 

 

 

文件指示

include引用其他的Makefile   

在Makefile使用include关键字可以把别的Makefile包含进来，这很像C语言的#include，被包含的文件会原模原样的放在当前文件的包含位置。

注：这个原样就是讲被include的文件直接放到指定的地方，原文件中的一切变量依旧有效。

 

include的语法是： include <filename>

filename可以是当前操作系统Shell的文件模式（可以保含路径和通配符） 在include前面可以有一些空字符，但是绝不能是[Tab]键开始。include和<filename>可以用一个或多个空格隔开。如果文件都没有指定绝对路径或是相对路径的话，make会在当前目录下首先寻找，如果当前目录下没有找到，那么，make还会在下面的几个目录下找：

1、如果make执行时，有“-I”或“--include-dir”参数，那么make就会在这个参数

所指定的目录下去寻找。

2、如果目录<prefix>/include（一般是：/usr/local/bin或/usr/include）存在的话，make也会去找。如果有文件没有找到的话，make会生成一条警告信息，但不会马上出现致命错误。它会继续载入其它的文件，一旦完成makefile的读取，make会再重试这些没有找到，或是不能读取的文件，如果还是不行，make才会出现一条致命信息。如果你想让make不理那些无法读取的文件，而继续执行，你可以在include前加一个减号“-”。

如： -include <filename>

其表示，无论include过程中出现什么错误，都不要报错继续执行。和其它版本make兼 容的相关命令是sinclude，其作用和这一个是一样的。

 

指定Makefile中的有效部分 

eg. C语言中的#if

定义一个多行的命令

 

生成多个目标的方法

 

 

menuconfig

make menuconfig命令没有指定文件，因此默认执行的是 make -f Makefile
menuconfig

关键字

ifeq、ifneq

使用条件判断，可以让make根据运行时的不同情况选择不同的执行分支。条件表达式可以是比较变量的值，或是比较变量和常量的值。

 

示例：
下面的例子，判断$(CC)变量是否“gcc”，如果是的话，则使用GNU函数编译目标。

libs_for_gcc = -lgnu

normal_libs =

foo: $(objects)

ifeq ($(CC),gcc)

$(CC) -o foo $(objects) $(libs_for_gcc)

else

$(CC) -o foo $(objects) $(normal_libs)

endif

可见，在上面示例的这个规则中，目标“foo”可以根据变量“$(CC)”值来选取不同的函数库来编译程序。

 

ifdef、ifndef

ifdef <variable-name>

如果变量<variable-name>的值非空，那到表达式为真。否则，表达式为假。当然，<variable-name>同样可以是一个函数的返回值。注意，ifdef只是测试一个变量是否有值，其并不会把变量扩展到当前位置。还是来看两个例子：

示例一： 

bar = 

foo = $(bar) 

ifdef foo 

frobozz = yes 

else 

frobozz = no 

endif 

示例二： 

foo = 

ifdef foo 

frobozz = yes 

else 

frobozz = no 

endif 

第一个例子中，“$(frobozz)”值是“yes”，第二个则是“no”。

 

 

函数

字符串处理函数

filter

$(filter <pattern...>,<text>)

名称：过滤函数——filter。

功能：以<pattern>模式过滤<text>字符串中的单词，保留符合模式<pattern>的单词。可以有多个模式。

返回：返回符合模式<pattern>的字串。

示例：

sources := foo.c bar.c baz.s ugh.h

foo: $(sources)

cc $(filter %.c %.s,$(sources)) -o foo

$(filter %.c %.s,$(sources))返回的值是“foo.c bar.c baz.s”。

 

返回列表中符合指定模式的字符串。

 

 

文件名函数

addprefix

$(addprefix
<prefix>,<names...>)

名称：加前缀函数——addprefix。

功能：把前缀<prefix>加到<names>中的每个单词后面。

返回：返回加过前缀的文件名序列。

示例：$(addprefix
src/,foo bar)返回值是“src/foo
src/bar”。

 

 

origin函数

origin函数不像其它的函数，他并不操作变量的值，他只是告诉你你的这个变量是哪里来的？其语法是：

$(origin <variable>)

注意，<variable>是变量的名字，不应该是引用。所以你最好不要在<variable>中使用“$”字符。Origin函数会以其返回值来告诉你这个变量的“出生情况”。

 

下面，是origin函数的返回值:

 “undefined”

如果<variable>从来没有定义过，origin函数返回这个值“undefined”。

“default”

如果<variable>是一个默认的定义，比如“CC”这个变量，这种变量我们将在后面讲述。environment” 如果<variable>是一个环境变量，并且当Makefile被执行时，“-e”参数没有被打开。

“file”

如果<variable>这个变量被定义在Makefile中。

“command line”

如果<variable>这个变量是被命令行定义的。

“override”

如果<variable>是被override指示符重新定义的。

“automatic”

如果<variable>是一个命令运行中的自动化变量。关于自动化变量将在后面讲述。

 

这些信息对于我们编写Makefile是非常有用的，例如，假设我们有一个Makefile其包了一个定义文件Make.def，在Make.def中定义了一个变量“bletch”，而我们的环境中也有一个环境变量“bletch”，此时，我们想判断一下，如果变量来源于环境，那么我们就把之重定义了，如果来源于Make.def或是命令行等非环境的，那么我们就不重新定义它。于是，在我们的Makefile中，我们可以这样写：

ifdef bletch

ifeq "$(origin bletch)"
"environment"

bletch = barf, gag, etc.

endif

endif

当然，你也许会说，使用override关键字不就可以重新定义环境中的变量了吗？为什么需要使用这样的步骤？是的，我们用override是可以达到这样的效果，可是override过于粗暴，它同时会把从命令行定义的变量也覆盖了，而我们只想重新定义环境传来的，而不想重新定义命令行传来的。

 

 

shell函数

shell函数也不像其它的函数。顾名思义，它的参数应该就是操作系统Shell的命令。它和反引号“`”是相同的功能。这就是说，shell函数把执行操作系统命令后的输出作为函数返回。于是，我们可以用操作系统命令以及字符串处理命令awk，sed等等命令来生成一个变量，如：

contents := $(shell
cat foo)

files := $(shell echo *.c)

注意，这个函数会新生成一个Shell程序来执行命令，所以你要注意其运行性能，如果你的Makefile中有一些比较复杂的规则，并大量使用了这个函数，那么对于你的系统性能是有害的。特别是Makefile的隐晦的规则可能会让你的shell函数执行的次数比你想像的多得多。

 

a=`whoami`                 反引号

#a=$(shell whoami)       推荐

#a=$(whoami) 若这样写 执行make do 会打印空行，按照上面两种方法那样写，会打印zhajindo:

       @echo $(a)

 

 

 

 

控制make的函数error和warning

make提供了一些函数来控制make的运行。通常，你需要检测一些运行Makefile时的运行时信息，并且根据这些信息来决定，你是让make继续执行，还是停止。

1、error

$(error <text ...>)

产生一个致命的错误，<text
...>是错误信息。注意，error函数不会在一被使用就会产生错误信息，所以如果你把其定义在某个变量中，并在后续的脚本中使用这个变量，那么也是可以的。例如：

示例一：

ifdef ERROR_001

$(error error
is $(ERROR_001))

endif

 

示例二：

ERR = $(error found
an error!)

.PHONY: err

err: ; $(ERR)

 

示例一会在变量ERROR_001定义了后执行时产生error调用，而示例二则在目录err被执行时才发生error调用。

 

2、warning

$(warning <text ...>)

这个函数很像error函数，只是它并不会让make退出，只是输出一段警告信息，而ma

ke继续执行。

 

 

 

make –C

“-C
<dir>”

“--directory=<dir>”

指定读取makefile的目录。如果有多个“-C”参数，make的解释是后面的路径以前面的作为相对路径，并以最后的目录作为被指定目录。如：“make –C ~hchen/test
–C prog”等价于“make –C ~hchen/test/prog”。

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

 

特殊用法

FORCE

 

helloworld:file1.o file2.o FORCE

gcc file1.o file2.o -o helloworld

 

PHONY  
+=FORCE

FORCE:

 

从上面看到，FORCE 既没有依赖的规则，其底下也没有可执行的命令。

如果一个规则没有命令或者依赖，而且它的目标不是一个存在的文件名，在执行此规则时，目标总会被认为是最新的。

 

 

如果一个规则没有命令或者依赖，而且它的目标不是一个存在的文件名。在执行此规则时，目  标总会被认为是最新的。就是说：这个规则一旦被执行， make 就认为它的目标已经被更新过。这  样的目标在作为一个规则的依赖时，因为依赖总被认为被更新过，因此作为依赖所在的规则定义的命令总会被执行。看一个例子：  

clean: FORCE  

rm $(objects)  

FORCE: 


这个例子中，目标“FORCE”符合上边的条件。它作为目标“clean”的依赖出现，在执行 make时，它总被认为被更新过。所以“clean”所在的规则在被执行时规则所定义的命令总会被执行。  

这样的一个目标通常我们将其命名为“FORCE”。  

上边的例子中使用“FORCE”目标的效果和我们指定“clean”为伪目标效果相同。两种方式  

相比较，使用“.PHONY”方式更加直观高效。这种方式主要用在非 GNU 版本的 make 中。 


在使用GNU make，尽量避免使用这种方式。  

 

 

 

 

 

 

 

 

 

 

 

 

首先编译目标all（第一个），分析依赖generate_files编译目标generate_files，并执行，建立目录mkdir –p /back-end-team/zhajin/data/nfs/rootfs，执行完后再执行all中的命令项



       @make
libs  -j$(jobs) $(SLIENT)  执行分析目标libs

       @make
targets  $(SLIENT)

libs:$(LIBS_PATH) FORCE，libs又依赖于一个目标$(LIBS_PATH)，其中，

LIBS_PATH    :=$(libs_src-y)，分析目标$(LIBS_PATH)

 

$(LIBS_PATH):FORCE


       make -C $@   

到LIBS_PATH（很多库的路径）中去分别执行make，生成许多.a的静态库

 

$(TARGETS_PATH):FORCE

       $(error error is 9)

       make -C $@

到TARGETS_PATH（目标路径）中去分别执行make，生成最终的目标文件

 

 

 

 

 

 

 

 

 

 

 

 

