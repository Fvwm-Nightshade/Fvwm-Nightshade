��    +      t  ;   �      �     �     �  0   �       8   $     ]  s   c  	   �  
   �     �  !   �               !     )     .  	   B     L     Q     e  	   l     v     �     �     �     �  e   �  G     7   \  H   �  H   �  ,   &     S  !   s  �  �  I   ;  #   �     �  8   �     �  ,   �     $  "  C  .   f     �  |   �  '   /  {   W     �  �   �  	   �     �     �  r   �  	   C     M     Z  
   i  =   t     �     �     �     �  
   �     
           ?     ^     l  �   y  �   _  z   #  y   �  w     Z   �  >   �  2   *  �  ]  ~   )  F   �)  %   �)  �   �)     �*  ^   �*  N   �*         )   $          !             &                                            +      *                          '   "               (           	   #                            
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
PO-Revision-Date: 2016-02-14 03:53+0200
Last-Translator: Artashes Mkhitaryan <artashm@mytum.de>
Language-Team: Russian
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
  Информация о Процессоре   данные о Ядрах  Добавить пользовательские настройки в авто-старт для постоянности. Добавить в авто-старт Параметры всех ядер будут установлены общим значениям! Продолжить? Применить Применить настройки к cpufreq системе. Так же сохранить их в $FVWM_USERDIR/.governor для употребления авто-стартом. Bogomips: процессоры: Отменить Отменить/Выйти из инструмента производительности процессора. Ядро  ошибка ошибка ! выход FNS Производительность процессора Регулятор: Информация Инфо о Ядре Вступил Кэш L2: продуцент: Максимум Частота: минимум Частота: Модель: Больше Не найдены установленные scaler-ы процессора.
Для полной функциональности необходима установка cpufreq-utils иле же cpupower как минимум. Не найдено ни одного активного драйвера для cpufreq!
 Невозможно применение FNS производительности процессора. Устанавливает глобальный регулятор (если ядра не разблокированы).  Устанавливает максимальную частоту из доступного сектора частот. Устанавливает минимальную частоту из доступного сектора частот. Установить регулятор (если ядро разблокировано).  Показать информацию о процессоре. Показать информацию о ядре. Последующие регуляторы доступны:

Производительный:
 Этот регулятор статически устанавливает частоту процессора на высочайшее значение в пределах Мин и Макс частот. Следовательно сбережение энергии не является фокусом этого регулятора.

 Энергосберегательнный: Частота процессора установлена на наименьшее возможное значение. Это может привести к сильному ухудшению производительности, поскольку частота процессора будет зафиксирована и не изменится в зависимости от его нагрузки.
Несмотря на это, употребления этого регулятора не всегда приводит к желанному уровню энергосбережения. Употребление энергии минимально когда система находится в холостых С-состояниях. Поскольку частота процессора зафиксирована на минимуме, процессы системы работают с меньшей скоростью и требуют больше времени для выполнения. В результате время в течении которого система может находится в холостых С-состояниях сокращается.

По-Запросу:
 Реализация ядра с динамичной стратегии установки частот: Регулятор наблюдает за нагрузкой процессора. Как только нагрузка процессора перешагнет через определенный порог, регулятор установит частоту процессора на высочайшую ступень. В ситуациях когда нагрузка процессора меньше порога, частота процессора устанавливается на ступень меньше. Если малая нагрузка системы продолжительна то частота процессора будет постепенноуменьшатся пока наименьшая ступень не достигнута. 

Консервативный: Так же как и реализация По-Запросу этот регулятор динамично настраивает частоту процессора соответственно  с нагрузкой системы. Разница между двумя регуляторами является в том что Консервативный регулятор позволяет постепенное повышение частот. Как только нагрузка системы перешагнет через определенный порог, регулятор увеличит частоту процессора на одну ступень выше.

Userspace: Этот регулятор позволяет пользователю, а так же любой программе работающей с UID 'root' в userspace-е, установить частоту на определенное значение. 'userspace' пока что не поддерживается, для получения аналогичных результатов рекомендуется использование энергосберегательного регулятора совместно с одной из 'Мин Частот', иле же производительного регулятора совместно с одной из 'Макс Частот'.  Этот таб для модификации всех не разблокированных ядер вместе взята. В этом табе можно модифицировать ядро  Разблокировать ядра Разблокировать ядра для установки частот и регуляторов по раздельности. Предупреждение Присутствуют не сохраненные изменения! Продолжить? если оно разблокировано в совместном табе. 