#
# chatterbox Progetto del corso di LSO 2017/2018
#
# Dipartimento di Informatica Università di Pisa
# Docenti: Prencipe, Torquati
#
#

##########################################################
# IMPORTANTE: completare la lista dei file da consegnare
#
FILE_DA_CONSEGNARE= DATA/chatty.conf1 DATA/chatty.conf2 chatty.c\
					client.c communication.h communication.c	\
					config.h connections.h connections.c		\
					delivery.h delivery.c errors.h errors.c		\
					fdSet.h fdSet.c groups.h groups.c history.h	\
					history.c income.h income.c listener.h		\
					listener.c logIn.h logIn.c membership.h		\
					membership.c message.h message.c ops.h 		\
					settings.h settings.c stats.h users.h 		\
					users.c utils.h utils.c script.sh 			\
					DoxyFile MainPage.dox						\
					Documentazione/Relazione.pdf				\
					Documentazione/Relazione.tex				\
					testconf.sh testfile.sh testgroups.sh 		\
					testleaks.sh teststress.sh 					\
					Makefile

# inserire il nome del tarball: es. NinoBixio
TARNAME=AlessandroMeschi
# inserire il corso di appartenenza: CorsoA oppure CorsoB
CORSO=CorsoA
#
# inserire l'email sulla quale ricevere comunicazione sul progetto
# e per sostenere l'esame
MAIL=alessandro.meschi@icloud.com
#
###########################################################

###################################################################
# NOTA: Il nome riportato in UNIX_PATH deve corrispondere al nome
#       usato per l'opzione UnixPath nel file di configurazione del
#       server (vedere i file nella directory DATA).
#       Lo stesso vale per il nome riportato in STAT_PATH e DIR_PATH
#       che deveno corrispondere con l'opzione StatFileName e
#       DirName, rispettivamente.
#
# ATTENZIONE: se il codice viene sviluppato sulle macchine del
#             laboratorio utilizzare come nomi, nomi unici,
#             ad esempo /tmp/chatty_sock_<numero-di-matricola> e
#             /tmp/chatty_stats_<numero-di-matricola>.
#
###################################################################
UNIX_PATH       = /tmp/chatty_socket
STAT_PATH       = /tmp/chatty_stats.txt
DIR_PATH        = /tmp/chatty

CC				=  gcc
AR              =  ar
CFLAGS	        += -std=c99 -Wall -pedantic -g -DMAKE_VALGRIND_HAPPY
ARFLAGS         =  rvs
INCLUDES		= -I.
LDFLAGS 		= -L.
OPTFLAGS		= #-O3
LIBS            = -pthread

# aggiungere qui altri targets se necessario
TARGETS		= chatty        \
			  client


# aggiungere qui i file oggetto da compilare
OBJECTS		=	utils.o			\
				settings.o		\
				connections.o	\
				communication.o	\
				errors.o		\
				delivery.o		\
				fdSet.o			\
				groups.o		\
				history.o		\
				income.o		\
				logIn.o			\
				membership.o	\
				message.o		\
				users.o			\
				listener.o

# aggiungere qui gli altri include
INCLUDE_FILES	= 	communication.h	\
		  			config.h		\
					connections.h 	\
					delivery.h		\
					errors.h		\
					fdSet.h			\
					groups.h		\
					history.h		\
					income.h		\
					listener.h		\
					membership.h	\
		  			message.h     	\
		  			ops.h	  		\
					settings.h		\
		  			stats.h       	\
					users.h			\
					utils.h


.PHONY: all clean cleanall test1 test2 test3 test4 test5 consegna
.SUFFIXES: .c .h

%: %.c
	$(CC) $(CFLAGS) $(INCLUDES) $(OPTFLAGS) -o $@ $< $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) $(INCLUDES) $(OPTFLAGS) -c -o $@ $<

all		: $(TARGETS)


chatty: chatty.o libchatty.a $(INCLUDE_FILES)
	$(CC) $(CFLAGS) $(INCLUDES) $(OPTFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS)

client: client.o connections.o message.h
	$(CC) $(CFLAGS) $(INCLUDES) $(OPTFLAGS) $(LDFLAGS) -o $@ $^ $(LIBS)

############################ non modificare da qui in poi

libchatty.a: $(OBJECTS)
	$(AR) $(ARFLAGS) $@ $^

clean		:
	rm -f $(TARGETS)

cleanall	: clean
	\rm -f *.o *~ libchatty.a valgrind_out $(STAT_PATH) $(UNIX_PATH)
	\rm -fr  $(DIR_PATH)

killchatty:
	killall -9 chatty

# test base
test1:
	make cleanall
	\mkdir -p $(DIR_PATH)
	make all
	./chatty -f DATA/chatty.conf1&
	./client -l $(UNIX_PATH) -c pippo
	./client -l $(UNIX_PATH) -c pluto
	./client -l $(UNIX_PATH) -c minni
	./client -l $(UNIX_PATH) -k pippo -S "Ciao pluto":pluto -S "come stai?":pluto
	./client -l $(UNIX_PATH) -k pluto -p -S "Ciao pippo":pippo -S "bene e tu?":pippo -S "Ciao minni come stai?":minni
	./client -l $(UNIX_PATH) -k pippo -p
	./client -l $(UNIX_PATH) -k pluto -p
	./client -l $(UNIX_PATH) -k minni -p
	killall -QUIT -w chatty
	@echo "********** Test1 superato!"

# test scambio file
test2:
	make cleanall
	\mkdir -p $(DIR_PATH)
	make all
	./chatty -f DATA/chatty.conf1&
	./testfile.sh $(UNIX_PATH) $(DIR_PATH)
	killall -QUIT -w chatty
	@echo "********** Test2 superato!"

# test parametri di configurazione e statistiche
test3:
	make cleanall
	\mkdir -p $(DIR_PATH)
	make all
	./chatty -f DATA/chatty.conf2&
	./testconf.sh $(UNIX_PATH) $(STAT_PATH)
	killall -QUIT -w chatty
	@echo "********** Test3 superato!"


# verifica di memory leaks
test4:
	make cleanall
	\mkdir -p $(DIR_PATH)
	make all
	./testleaks.sh $(UNIX_PATH)
	@echo "********** Test4 superato!"

# stress test
test5:
	make cleanall
	\mkdir -p $(DIR_PATH)
	make all
	./chatty -f DATA/chatty.conf1&
	./teststress.sh $(UNIX_PATH)
	killall -QUIT -w chatty
	@echo "********** Test5 superato!"

# target per la consegna
consegna:
	make test1
	sleep 3
	make test2
	sleep 3
	make test3
	sleep 3
	make test4
	sleep 3
	make test5
	sleep 3
	tar -cvf $(TARNAME)_$(CORSO)_chatty.tar $(FILE_DA_CONSEGNARE)
	@echo "*** TAR PRONTO $(TARNAME)_$(CORSO)_chatty.tar "
	@echo "Per la consegna seguire le istruzioni specificate nella pagina del progetto:"
	@echo " http://didawiki.di.unipi.it/doku.php/informatica/sol/laboratorio17/progetto"
	@echo

# target per la compressione dei files da consegnare
tar:
	tar -cvf $(TARNAME)_$(CORSO)_chatty.tar $(FILE_DA_CONSEGNARE)
