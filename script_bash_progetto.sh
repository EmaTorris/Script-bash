 #
 # chatterbox Progetto del corso di LSO 2017/2018
 #
 # Dipartimento di Informatica Università di Pisa
 # Docenti: Prencipe, Torquati
 #
 #  Autore: Emanuele Torrisi
 #  Si dichiara che il contenuto di questo file è in ogni sua parte opera
 #  originale dell'autore
 #


#! /bin/bash

#controllo se il numero dei paramentri passati allo script siano 2 o 3 nel caso in cui passo l'opzione "--help"

if  [ $# != 2 ] && [ $# != 3 ]; then
	echo "Non ci sono abbastanza argomenti in input. Modalità d'uso dello script $0: file.conf intero" 1>&2
	exit 1
fi

#controllo se il file esiste e se è un file leggibile
if ! [[ -f $1  &&  -r $1 ]]; then
	echo "Il file passato come primo parametro non è un file appropriato. Usare: file.conf"
	exit 2
fi

#se i parametri passati sono 3 controllo che uno dei parametri sia "--help" altrimenti stampo errore
if [ $# = 3 ]; then
	for elem in "$@"; do
		if [ "$elem" = "--help" ]; then
			echo "Modalità d'uso dello script $0: file.conf intero" 1>&2
			exit 1
		fi
	done
fi

#salvo il file .conf in una variabile e verifico se DirName esiste nel file.conf
#grep -c "DirName" conta le occorrenze di "DirName" all'interno del file $1
File=$(cat $1 | grep -c "DirName")


if [ $File -eq 0 ]; then
   #stringa non contenuta nel file
   echo "Errore: non posso prendere il nome della cartella" 1>&2
   exit 2
else
   #stringa contenuta nel file
   File="$(cat $1)"
   #utilizzo ## in modo tale da non fermarmi alla prima occorrenza di "DirName" nel file config ottenendo la
   #stringa sbagliata quindi elimino tutto il prefisso dell'ultima occorrenza di DirName all'interno del file
   File=${File##*"DirName"}
   #echo "$File"
   File=${File%%"#"*}
   #echo "$File"
   File=${File##*"="}
   #echo "$File"
  
   File=$(echo "$File" | tr -s " ")
   File=${File%% }
   File=${File## }
   File1=${File%"/"*}
   #echo "$File"
  
fi


#echo "${File}"

Tempo=$2

if [ $Tempo -lt 0 ]; then
	echo "Errore: il numero inserito non è un intero maggiore di 0" 1>&2
	exit 2
	
elif [ $Tempo -gt 0 ]; then
	NomeCartella='/cartellaaux'
	NomeCartella1="$File1$NomeCartella"
	echo "$NomeCartella1"
	mkdir -p $NomeCartella1
	ArrayFile=(`find ${File} -name "*" `)
	for ((i=0; i<${#ArrayFile[@]}; i++)); do
		#echo "${ArrayFile[i]}"
		#tempo attuale trasformato in minuti dal 01-01-1970
		TempoAttuale=$(date +%s)
		TempoAttuale=$((TempoAttuale / 60))
		#tempo del file trasformato in minuti dal 01-01-1970
		TempoFile=$(date +%s -r ${ArrayFile[i]})
		TempoFile=$((TempoFile / 60))
		#tempo del file calcolato in minuti dal momento della sua creazione
		TempoTotale=$(( ($TempoAttuale - $TempoFile) ))
		#echo "$TempoTotale minuti"
		if [ $TempoTotale -gt $Tempo ]; then
			cp --parents "${ArrayFile[i]}" "$NomeCartella1/"
			#-i chiede la conferma per ogni file
			#-R rimuove ricorsivamente le cartelle e i loro contenuti
			#-v spiega cosa è stato fatto
			#-d cancella anche le cartelle vuote
		fi
	done
	tar cf myfiles.tar.gz $NomeCartella1
	mv myfiles.tar.gz $File
	rm -Rvd $NomeCartella1
	rm -iRvd $File/myfiles.tar.gz

elif [ $Tempo -eq 0 ]; then
	ArrayFile=(`find ${File} -name "*" `)
		for ((i=0; i<${#ArrayFile[@]}; i++)); do
			if [ -f ${ArrayFile[i]} ]; then
				NomeFile=${ArrayFile[i]##*/}
				echo "$NomeFile" 1>&2
			fi
		done 
fi
