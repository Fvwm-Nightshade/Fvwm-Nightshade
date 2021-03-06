��    +      t  ;   �      �     �     �  0   �       8   $     ]  s   c  	   �  
   �     �  !   �               !     )     .  	   B     L     Q     e  	   l     v     �     �     �     �  e   �  G     7   \  H   �  H   �  ,   &     S  !   s  �  �  I   ;  #   �     �  8   �     �  ,   �     $  5  C     y     �  8   �     �  X   �     J  {   R  	   �     �     �  /   �          (     .     6     =     Q     ]     b     v  
        �     �     �     �     �  |   �  U   >  P   �  P   �  P   6  D   �  "   �  (   �  u    ^   �  .   �       L   1     ~  :   �  0   �         )   $          !             &                                            +      *                          '   "               (           	   #                            
                      %     CPU Information   Information to Cores  Add custom settings to autostart for permanency. Add to Autostart All cores will be set to common values! Continue anyway? Apply Apply settings to the cpufreq system. Also save them in $FVWM_USERDIR/.governor for using it with autostart if set. Bogomips: CPU Count: Cancel Cancel/Quit Cpu Performance tool. Core  Error Error ! Exit FNS Cpu Performance Governor: Info Information to Core Joined L2 Cache: Manufacturer: Max Frequency: Min Frequency: Model: More No cpu scaler is installed.
For full functionality cpufreq-utils or cpupower must installed at least. No or unknown cpufreq driver is active!
FNS Cpu Performance not usable. Sets the global used governor (if cores not unlocked).  Sets the maximum used frequency from the range of available frequencies. Sets the minimum used frequency from the range of available frequencies. Sets the used governor (if cores unlocked).  Show information about the cpu. Show information about this core. The following governors are available:

Performance:
This governor sets the CPU statically to the highest frequency within the borders of Min Frequency and Max Frequency. Consequently, saving power is not the focus of this governor.

Powersave:
The CPU frequency is statically set to the lowest possibility. This can have severe impact on the performance, as the system will never rise above this frequency no matter how busy the processors are.
However, using this governor often does not lead to the expected power savings as the highest savings can usually be achieved at idle through entering C-states. Due to running processes at the lowest frequency with the powersave governor, processes will take longer to finish, thus prolonging the time for the system to enter any idle C-states.

On-demand:
The kernel implementation of a dynamic CPU frequency policy: The governor monitors the processor utilization. As soon as it exceeds a certain threshold, the governor will set the frequency to the highest available. If the utilization is less than the threshold, the next lowest frequency is used. If the system continues to be underutilized, the frequency is again reduced until the lowest available frequency is set.

Conservative:
Similar to the on-demand implementation, this governor also dynamically adjusts frequencies based on processor utilization, except that it allows for a more gradual increase in power. If processor utilization exceeds a certain threshold, the governor does not immediately switch to the highest available frequency (as the on-demand governor does), but only to next higher frequency available.

Userspace:
This governor allows the user, or any userspace program running with UID 'root', to set the CPU to a specific frequency. 'userspace' is not supported yet, but to get the same result use governor 'powersave' and one of the frequencies in 'Min Frequency', or governor 'performance' in combination with 'Max Frequency'. This is the tab for modifying ALL cores together if they're not unlocked. This is the tab for modifying core  Unlock cores Unlock cores to set governor and frequencies separately. Warning You have unapplied changes! Continue anyway? if unlocked at the joined tab. Project-Id-Version: fns-cpu-performance
POT-Creation-Date: 2014-12-08 23:37+0200
PO-Revision-Date: 2015-02-16 18:51+0200
Last-Translator: Adonai Martin <adonai.martin@gmail.com>
Language-Team: Spanish
Language: Spanish
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
  Información CPU   Informes a Núcleos  Añadir ajustes a medida a auto-inicio para permanencia. Añadir a Auto-inicio ¡Se establecerán valores comunes para todos los núcleos! ¿Continuar de todas formas? Aplicar Aplicar ajustes a la cpufreq del sistema. Guardarlos en $FVWM_USERDIR/.governor para usarlo con auto-inicio si establecido. Bogomips: Número CPUs: Cancelar Cancelar/Cerrar herramienta de rendimiento CPU. Núcleo  Error Error ! Salida FNS Rendimiento CPU Gobernante: Info Informes al Núcleo Acoplado Caché L2: Fabricante: Frec. máxima: Frec. mínima: Modelo: Más Ningún CPU-Scaler está instalado.
Para una funcionalidad completa de cpufreq-utils o cpupower debe ser instalado al menos. No o controlador cpufreq desconocido está activo!
FNS Rendimiento CPU no utilizable. Establece el gobernante global usado (si los núcleos no están desbloqueados).  Establece la máxima frecuencia usada desde el rango de frecuencias disponibles. Establece la mínima frecuencia usada desde el rango de frecuencias disponibles. Establece el gobernante usado(si los núcleos están desbloqueados). Mostrar información sobre la CPU. Mostrar información sobre este núcleo. Los siguientes gobernantes están disponibles:

Rendimiento:
Este gobernante fija la CPU a la mayor frecuencia dentro de los límites mínimo y máximo de frecuencia.

Por consiguiente, el ahorro de energía no es el objetivo de este manejador.

Ahorro de energía:
La frecuencia de CPU se fija al menor valor posible. Esto puede tener un severo impacto en el rendimiento, siempre y cuando el sistema nunca aumentará esta frecuencia sin importar la carga de los procesadores.
El uso de este manejador, a menudo no conduce al ahorro de energía esperado ya que el mayor ahorro se consigue normalmente en el modo inactivo al entrar en los C-states. Debido al uso de una menor frecuencia con el gobernante de ahorro de energía, los procesos tardarán más tiempo en terminar, lo que conlleva un mayor intervalo de tiempo para entrar en los C-states.

Bajo demanda:
La implementación del núcleo de una política de frecuencia dinámica de CPU: El manejador monitorea el uso del procesador. Tan pronto como se exceda un cierto umbral, el manejador establecerá la la mayor frecuencia disponible. Si el uso es menor que el umbral, la siguiente menor frecuencia será usada. Si el sistema continúa siendo infrautilizado, la frecuencia es de nuevo reducida hasta que la más baja disponible sea establecida.

Conservativo:
Similar a la implementación bajo demanda, este manejador también ajusta dinámicamente a las frecuencias basadas en el uso del procesador, a excepción de esto, permite un mayor incremento gradual de potencia. Si el uso del procesador excede un cierto umbral, el manejador no cambia immediatamente a la más alta frecuencia disponible (como el manejador bajo demanda), pero sólo a la siguiente mayor frecuencia disponible.

Espacio de usuario:
Este manejador permite al usuario, o a cualquier programa en ejecución de espacio de usuario con UID 'root', establecer la CPU a una frecuencia específica. 'espacio de usuario' no está soportada todavía, pero para obtener el mismo resultado, usa el manejador de 'ahorro de potencia' y una de las frecuencias en 'Mín Frecuencia', o manejador 'rendimiento' en combinación con 'Máx Frecuencia'. Esta es la pestaña para modificar TODOS los núcleos a la vez si no estuvieran desbloqueados. Esta es la pestaña para modificar el núcleo  Desbloquear núcleos Desbloquear núcleos para establecer gobernante y frecuencias separadamente. Advertencia ¡Tiene cambios no aplicados! ¿Continuar de todas formas? si está desbloqueado en la pestaña 'Acoplado'. 