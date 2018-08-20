Compresor de archivos
<ul>
  <li>Para correrlo se necesita TASM y TLINK.</li>
<li>Este es un programa que comprime y descomprime archivos </li>
<li>Para comprimir se introduce en la linea de comandos la opcion -c seguida del pathname de un archivo txt</li>
<li>El producto de esta operacion es un archivo .rlp</li>
<li>Para comprimir lo que hace el programa es tomar los 15 caracteres mas comunes y reemplazarlos por un codigo de un nible de tamaño</li>
<li>El resto los deja con su ascii normal</li>
<li>Ademas de eso, en la pantalla se muestra el tamano del archivo original, del compreso y el porcentaje de compresion</li>
<li>Ademas se incluyen los 15 caracteres mas comunes en el archivo (los que se reemplazaron por un codigo de un nible), seguidos de cuantas veces aparecen en el archivo</li>
<li>Si un caracter de los mas comunes es uno de formato, entonces lo que se muestra es el nemonico ascii que lo representa (ej, spc = espacio, cr = retorno de carro)</li>
<li>Para descomprimir se introduce en la linea de comandos la opcion -d seguida del pathname de un archivo .rlp </li>
<li>El resultado de este procedimiento es un archivo .txt del mismo nombre que el archivo de la entrada con el texto descomprimido</li>
<li>Para observar la ayuda se puede introducir la opcion -a o simplemente no introducir nada en la linea de comandos despues de invocar al programa</li>
 </ul>
