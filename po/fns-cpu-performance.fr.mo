��    +      t  ;   �      �     �     �  0   �       8   $     ]  s   c  	   �  
   �     �  !   �               !     )     .  	   B     L     Q     e  	   l     v     �     �     �     �  e   �  G     7   \  H   �  H   �  ,   &     S  !   s  �  �  I   ;  #   �     �  8   �     �  ,   �     $  5  C     y     �  L   �     �  M     	   P  �   Z  	   �     �     �  )   �     '     -     4     =     D  	   [     e     k     �  	   �  
   �     �     �     �     �  u   �  O   @  I   �  Q   �  Q   ,  H   ~  )   �  .   �  3	     Q   T  #   �     �  R   �     7   C   E      �          )   $          !             &                                            +      *                          '   "               (           	   #                            
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
PO-Revision-Date: 2015-02-16 18:55+0200
Last-Translator: Maxime Lordier <maxime.lordier@gmail.com>
Language-Team: French
Language: French
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
  Information CPU   Information des cores  Ajoutez de facon permanente les paramêtrez de customisation pour autostart. Ajoutez Autostart Tous les cores seront mis à leur valeurs initiale! Souhaitez-vous continuer? Appliquer Appliquez les paramêtres système cpufreq. Sauvegardé les dans $FVWM_USERDIR/.governor pour l'utiliser si autostart est activé. Bogomips: Compteur CPU: Annuler Annuler/Quitter CPU outil de performance. Core  Erreur Erreur ! Sortie FNS Performance du CPU Governor: Infos Information des cores Joind L2 Cache: Fabricant: Fréquence max: Fréquence min: Modèle: Plus Pas de cpi scaler installé.
For plein de fonctionnalité cpufreq-utils ou cpupower doivent être au moins installé. Non ou pilote cpufreq inconnue est active!
FNS Performance du CPU inutilisable. Activez le gouvernor global utilisé (si les cores sont déverroullés).  Appliquez la fréquence maximale utilisée de léchelle de fréquence disponible. Appliquez la fréquence minimale utilisée de léchelle de fréquence disponible. Activez le gouvernor global utilisé (si les cores sont déverroullés). Montrez les information à propos du CPU. Affichez les information à propos de ce core. Les gouvernors suivantes sont disponibles:

Performance:
Ce gouvernor définit le CPU statiquement à la fréquence la plus élevée dans les frontières Fréquence de Min et Max Fréquence. Par conséquent, l'économie d'énergie ne est pas l'objet de ce gouvernor.

Économie d'énergie:
Le fréquence du CPU est statiquement à la possibilité bas Cela peut avoir de graves impact sur la performance, car le système ne sera jamais élever au-dessus de cette fréquence ne importe comment occupé les processeurs sont.
Toutefois, en utilisant ce gouvernor souvent ne conduit pas à la puissance attendue économies que les économies les plus élevées peuvent généralement être atteints au ralenti travers entrant C-états. En raison à des processus à la fréquence la plus basse courir avec le gouvernor powersave, processus prendra plus de temps pour terminer, prolongeant ainsi le temps pour le système de pénétrer dans les C-états de repos.

Sur demande:
La mise en œuvre du noyau d'une politique dynamique de la fréquence du processeur: Les moniteurs de gouvernor l'utilisation du processeur. Dès qu'il dépasse un certain seuil, le gouvernor donnera le à la fréquence la plus élevée disponible. Si l'utilisation est inférieur au seuil, le prochain fréquence la plus basse est utilisée. Si le système continue à être sous-utilisés, la fréquence est à nouveau réduite jusqu'à la plus basse fréquence disponible est défini.

Conservateur:
Similar à la mise en œuvre à la demande, ce gouvernor a également ajuste dynamiquement fréquences sur la base de l'utilisation du processeur, sauf qu'elle permet une augmentation plus progressive dans puissance. Si l'utilisation du processeur dépasse un certain seuil, le gouvernor ne est pas immédiatement passer à la plus haute fréquence disponibles (comme le gouvernor à la demande fait), mais seulement jusqu'à la prochaine supérieur fréquence disponible.

Userspace:
Ce gouvernor permet à l'utilisateur, ou tout autre programme en espace utilisateur courant avec 'root' UID, à mettre la CPU à une fréquence spécifique. 'espace utilisateur' ne est pas encore pris en charge, mais pour obtenir le même résultat utilisation gouvernor 'PowerSave' et l'une des fréquences dans 'Min Fréquence', ou gouvernor 'performance' en combinaison avec 'Fréquence Max'. Cet onglet est pour la modification de tout les cores,si nesont pas verrouillés. Cet onglet pour modifier les cores  Déverrouilléz les cores Déverrouilléz les cores pour modifier le governor et la fréquence séparemment. Avertissement Vous n'avez pas appliqué les changement! Souhaitez-vous continuer? Si de 