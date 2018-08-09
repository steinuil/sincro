(require [sincro.util [*]])
(import time)

(defclass Ping [object]
  "Keeps track of the last ping and of the
  exponentially weighted moving average (EWMA) of all the pings"
  [*warmup* 10 ; samples to collect before seeding the EWMA
   *decay* 0.7
   ;; The decay factor, or alpha, which determines how much sudden spikes
   ;; in the values affect the average.
   ;; A factor close to 0 is more sensible, close to 1 is more sturdy.
   samples 0 ; total number of samples
   average-rtt []
   last-rtt None
   last-forward-delay None]

  (defm add [timestamp sender-rtt]
    (setv rtt (- (time.time) timestamp)
          self.last-rtt rtt)
    (incv self.samples)

    ;; Append the values to a list until we have enough samples,
    ;; then swap out the list with its average and start calculating the EWMA.
    (if (> self.samples self.*warmup*)
      (setv self.average-rtt (+ (* rtt self.*decay*)
                                (* rtt (- 1 self.*decay*))))
      (do
        (.append self.average-rtt rtt)
        (when (= self.samples self.*warmup*)
          (setv self.average-rtt (/ (sum self.average-rtt) self.*warmup*)))))

    (setv self.last-forward-delay
          (if (< sender-rtt rtt)
            (+ (/ (self.average) 2)
               (- rtt sender-rtt))
            (/ (self.average) 2))))

  (defm average []
    "Return the average ping"
    (if (< self.samples self.*warmup*)
      ;; Return a simple average until we're warmed up
      (/ (sum self.average-rtt) (len self.average-rtt))
      self.average-rtt)))
