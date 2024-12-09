# Proyecto Final

Integrantes:

- Jose Laurent Chaves - B63761
- Heiner Obando Vega - B55130
- Fabricio Salazar Alavarado - B87179

## Instrucciones para poder utilizar el código:

El código fue realizado utilizando Ubuntu, por lo que es importante trabajar en un ambiente Linux. Se utiliza Icarus como compilador, la aplicación Gtkwave, así como make para poder utilizar el makefile creado. Realizando la copia del repositorio de Github a nivel local, el usuario debe estar ubicado en la carpeta src y utilizando los siguientes comandos del Makefile puede obtener diferentes resultados:

    - make PCS: Se obtienen los resultados de la simulación del bloque PCS completo.
    
    - make sync: Se obtienen los resultados de la simulación realizada sobre el sincronizador.

Fue agregado un archivo .gtkw para cada grupo de ondas, por lo que, dentro de la aplicación Gtkwave cuando se abra se puede ir a File - Read Save File y elegir el archivo .gtkw que corresponda a cada prueba (tienen el mismo nombre de los archivos .vcd creados).

## Explicación del proyecto que se debía realizar

El siguiente repositorio contiene el código para la elaboración del proyecto final dentro de la carpeta **src**. El proyecto consite en diseñar un bloque de la subcapa de codificación física (PCS, por sus siglas en inglés), de acuerdo con las especificaciones de la cláusula 36 del estándar IEEE 802.3.

1. El bloque de PCS diseñado debe contar con las interfaces (entradas y salidas) que se muestran en la figura 36-2 y las máquinas de estado deben responder a los diagramas de estados de la sección 36.2.5.2. Para efectos del banco de pruebas, se debe conectar las salidas tx_code_group a las entradas rx_code_group, de modo que el bloque de PCS
quede configurado en modo de loopback. Es decir, que los datos que se transmiten por el camino de TX vuelvan a pasar por el PCS en la dirección opuesta, el camino de RX.
2. Como prueba mínima del funcionamiento correcto del bloque de PCS, se espera una
prueba de loopback que envíe una trama completa de Ethernet.
3. Se debe escribir una descripción conductual del PCS usando Verilog. Esta descripción servirá como una
especificación detallada y formal del funcionamiento del dispositivo diseñado.
4. La descripción en Verilog deberá tener al menos un módulo de banco de pruebas, un
módulo probador, un módulo de “envoltorio” (wrapper) que contenga a todos los
submódulos del PCS y al menos un submódulo para cada máquina de estados .
5. Se debe definir un plan de pruebas para garantizar el funcionamiento del diseño. El plan de
pruebas debe incluir, como mínimo, la prueba de loopback.

# Diseño Arquitectónico

Para entendimiento del lector se colocan los diagramas ASM de las diferente máquinas de estado.

## Transmisor

El transmisor cuenta con dos máquinas de estado, la primer máquina de estados es la encargada de controlar los conjuntos ordenados, es decir, definir los códigos y datos que se desean que sean enviados, para la transmisión estos datos recibidos en 8 bits son enviados primeramente a la máquina de estados encargada de la codificación, el flujo de trabajo de esta máquina de estados se muestra por medio de su diagrama ASM en la siguiente Figura.

<a><img src="https://github.com/HeinerOV97/Imagenes/blob/main/ENVIA_DATOS.png"></a>

La segunda máquina de estados se encarga de realizar la codificación, ya que los datos recibidos del GMII serán de 8 bits, pero para enviarlos deberán ser codificados a 10 bits. El diagrama ASM de esta máquina se muestra en la siguiente Figura.

<a><img src="https://github.com/HeinerOV97/Imagenes/blob/main/CODIFICADOR.png"></a>

## Sincronizador

El sincronizador por su parte se encarga de que el receptor entre en sincronía con el transmisor y se pueda dar el correcto envío de datos desde el transmisor al receptor. El diagrama ASM se muestra en la siguiente Figura

<a><img src="https://github.com/HeinerOV97/Imagenes/blob/main/SINCRONIZADOR.png"></a>

## Receptor

El receptor al estar en sincronía con el transmisor, este decodificará los 10 recibidos pasándolos a datos de 8 bits, y los enviará a la capa GMI. En la siguiente Figura se muestra el diagrama ASM de la máquina de estados del receptor.

<a><img src="https://github.com/HeinerOV97/Imagenes/blob/main/estados_receptor.PNG"></a>

