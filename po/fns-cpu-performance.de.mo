��    +      t  ;   �      �     �     �  0   �       8   $     ]  s   c  	   �  
   �     �  !   �               !     )     .  	   B     L     Q     e  	   l     v     �     �     �     �  e   �  G     7   \  H   �  H   �  ,   &     S  !   s  �  �  I   ;  #   �     �  8   �     �  ,   �     $  #  C     g     {  Y   �     �  D        J  �   S  	   �       	     1        K     Q     X     a     i  	   �     �     �  	   �  	   �     �     �     �     �     �  y   �  _   h  C   �  N     N   [  B   �  "   �  #       4  Q   T  *   �     �  K   �     .  =   6  3   t         )   $          !             &                                            +      *                          '   "               (           	   #                            
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
PO-Revision-Date: 2015-02-16 18:45+0200
Last-Translator: Thomas Funk <t.funk@web.de>
Language-Team: German
Language: de
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
  CPU Informationen   Infos zu den Kernen  Fügt die Benutzer-Einstellungen zum Autostart hinzu, damit sie dauerhaft aktiviert sind. Hinzufügen zum Autostart Alle Kerne werden auf gemeinsame Werte gesetzt! Trotzdem fortfahren? Anwenden Wendet die Einstellungen auf das Cpufreq-System an. Ausserdem werden sie in $FVWM_USERDIR/.governor gespeichert, falls sie über den Autostart gesetzt werden wollen. Bogomips: CPU Anzahl: Abbrechen Abbrechen/Beenden der CPU Leistungseinstellungen. Kern  Fehler Fehler ! Beenden FNS CPU Leistungseinstellungen Governor: Info Infos zum Kern Gekoppelt L2 Cache: Hersteller: Max Frequenz: Min Frequenz: Model: Mehr Kein Cpu-Scaler ist installiert.
Für volle Funktionalität muss mindestens cpufreq-utils oder cpupower installiert sein. Keiner oder unbekannter cpufreq-Treiber aktiv!
FNS CPU Leistungseinstellungen nicht verwendbar! Setzt den globalen Governor (wenn die Kerne nicht entsperrt sind).  Setzt die maximal zu benutzende Frequenz aus den möglichen Frequenzbereichen. Setzt die minimal zu benutzende Frequenz aus den möglichen Frequenzbereichen. Setzt den zu benutenden Governor (wenn die Kerne entsperrt sind).  Zeigt Informationen über die Cpu. Zeigt Informationen zu diesem Kern. Folgende Governors sind verfügbar:

Performance:
setzt die CPU statisch auf die höchste Frequenz, die zwischen Min und Max Frequenz möglich ist. Infolgedessen ist Energiesparen nicht im Fokus dieses Governors.

Powersave:
Die CPU-Frequenz ist hier statisch auf den niedrigsten Wert gesetzt. Dies kann ernstliche Folgen für die Performance haben, da das System nie höher wie die eingestellte Frequenz takten kann, egal wie beschäftigt die Kerne gerade sind.
Es werden, anders als angenommen, mit diesem Governor nicht die zu erwarteten Stromeinsparungen erreicht, sondern durch das Wechseln in andere C-States während des Leerlaufs.
Da laufende Prozesse auf der niedriegsten Frequenz arbeiten müssen, brauchen sie länger, um fertig zu werden. Somit verlängert sich die Zeit, die das System nicht im Leerlauf verbringen kann, um in die stromsparenden C-States zu wechseln.

On-demand:
Der Governor überwacht die Prozessorauslastung (im Kernel implementierte dynamische Frequenz-Strategie). Wenn die Auslastung einen bestimmten Schwellwert übeschreitet, wechselt er auf die höchstmögliche Frequenz. Unterschreitet sie den Schwellwert wieder, wird auf die nächst kleinere geschaltet. Bleibt die Auslastung weiter niedrig, wird weiter auf die nächst kleinere Frequenz gewechselt, bis die niedrigste Frequenz, die möglich ist, erreicht wurde.

Conservative:
Wie bei der on-demand Implementierung, passt dieser Governor die Frequenzen dynamisch zur CPU-Auslastung an, jedoch wird die Leistung allmählich angehoben. Wenn die Prozessorauslastung einen gewissen Schwellwert überschreitet, wechselt der Governor nicht sofort zur höchstmöglichen Frequenz (wie der on-demand Governor), sondern zur nächst höheren.

Userspace:
Dieser Governor erlaubt dem Benutzer, oder jedem anderen Benutzerprogramm, das mit der UUID 'root' läuft, die CPU auf eine bestimmte Frequenz zu setzen. 'Userspace' wird derzeit nicht unterstützt, aber man kann das gleiche Verhalten mit 'Powersave' und einer der Min Frequenzen, oder mit 'Performance' und einer der Max Frequenzen erreichen. Dieser Tab ist zum gemeinsamen modifizieren ALLER Kerne, wenn sie entsperrt sind. Das ist der Tab zum modifizieren des Kern  Kerne entsperren Entsperren der Kerne, um den Governor und die Frequenzen seperat zu setzen. Warnung Sie haben nicht angewendete Änderungen! Trotzdem fortfahren? , wenn im Tab 'Gekoppelt' die Kerne entsperrt sind. 