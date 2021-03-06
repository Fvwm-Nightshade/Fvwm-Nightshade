��    +      t  ;   �      �     �     �  0   �       8   $     ]  s   c  	   �  
   �     �  !   �               !     )     .  	   B     L     Q     e  	   l     v     �     �     �     �  e   �  G     7   \  H   �  H   �  ,   &     S  !   s  �  �  I   ;  #   �     �  8   �     �  ,   �     $  D  C     �     �  E   �     �  O     	   a  �   k  	               +   #     O     V     ]     f     m     �     �     �     �  	   �  
   �     �     �     �     �  �   �  O   �  Q   �  S   *  S   ~  B   �  )     /   ?  �	  o  `   �  &   S      z   T   �      �   F   �   (   >!         )   $          !             &                                            +      *                          '   "               (           	   #                            
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
PO-Revision-Date: 2016-02-14 03:49+0200
Last-Translator: Dominique Michel <dominique_libre@users.sourceforge.net>
Language-Team: French
Language: French
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
  Information CPU   Information des coeurs  Ajoutez de facon permanente les paramêtrez personnels au démarrage. Ajoutez automatiquement Tous les coeurs seront mis à des valeurs communes ! Souhaitez-vous continuer ? Appliquer Appliquez les paramêtres au système cpufreq, et les sauver dans $FVWM_USERDIR/.governor pour utilisation lorsque Ajoutez automatiquement est activé. Bogomips: Nombre d CPU: Annuler Annuler/Quitter l'outil de performance CPU. Coeur  Erreur Erreur ! Sortie FNS Performance du CPU Gouverneur: Information Information du coeur Joints Cache L2: Fabricant: Fréquence max: Fréquence min: Modèle: Plus Pas de controleur de cpu installé.
Pour obtenir toutes les fonctionnalités, au moins un de cpufreq-utils ou cpupower doit être installé. Non ou pilote cpufreq inconnue est active!
FNS Performance du CPU inutilisable. Activez le gouverneur global utilisé (si les coeurs ne sont pas déverroullés). Règlez la fréquence maximale utilisée de l'échelle des fréquences disponibles. Règlez la fréquence minimale utilisée de l'échelle des fréquences disponibles. Règle le gouverneur utilisé (si les cores sont déverroullés).  Montrez les information à propos du CPU. Affichez les information à propos de ce coeur. Les gouverneurs suivants sont disponibles:

Performance:
Ce gouverneur règle le CPU statiquement à la fréquence la plus élevée entre les frontières de Fréquence min et Fréquence max. Par conséquent, l'économie d'énergie n'est pas l'objet de ce gouverneur.

Économie d'énergie:
Le CPU est règlé statiquement à la fréquence la plus basse possible. Cela peut avoir de graves impacts sur la performance, car le système ne sera jamais élevé au-dessus de cette fréquence sans égard pour le taux d'occupation des processeurs.
Toutefois, l'utilisation de ce gouvernor ne conduit souvent pas aux économies de puissance attendues car les économies les plus élevées peuvent généralement être atteintes au repos en entrant dans les états C. En travaillant à la fréquence la plus basse, les processus gérés par le gouverneur powersave prendront plus de temps pour se terminer, prolongeant ainsi le temps nécessaaire au système pour entrer dans les états C de repos.

À la demande:
Mise en œuvre par le noyau d'une politique dynamique de la fréquence du processeur: Le gouverneur surveille l'utilisation du processeur. Dès qu'elle dépasse un certain seuil, le gouverneur règlera la fréquence à la valeur la plus élevée disponible. Si l'utilisation est inférieure au seuil, la prochain fréquence plus basse est utilisée. Si le système continue à être sous-utilisé, la fréquence est à nouveau réduite jusqu'à obtention de la plus basse fréquence disponible.

Conservateur:
Similaire à la mise en œuvre à la demande, ce gouverneur ajuste aussi dynamiquement les fréquences sur la base de l'utilisation du processeur, sauf qu'il permet une augmentation plus progressive de la puissance. Si l'utilisation du processeur dépasse un certain seuil, le gouvernor n'est pas immédiatement passé à la plus haute fréquence disponible (comme le fait le gouverneur à la demande), mais seulement jusqu'à la prochaine fréquence supérieure disponible.

Espace utilisateur:
Ce gouverneur permet à l'utilisateur, ou à tout autre programme de l'espace utilisateur travaillant avec l'UID 'root', de mettre le CPU à une fréquence spécifique. 'espace utilisateur' n'est pas encore pris en charge, mais pour obtenir le même résultat utiliser le gouverneur 'Économie d'énergie' et l'une des fréquences dans 'Fréquence min', ou le gouverneur 'Performance' en combinaison avec 'Fréquence max'. Cet onglet est pour la modification de tous les coeurs ensemble, s'ils ne sont pas verrouillés. C'est l'onglet pour modifier le coeur  Déverrouiller les coeurs Déverrouiller les coeurs pour modifier séparemment le gouverneur et la fréquence. Avertissement Vous n'avez pas appliqué les changements ! Souhaitez-vous continuer ?  si dévérouillé dans l'onglet Joints. 