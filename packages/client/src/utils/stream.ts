import { useEffect } from "react";
import { Observable } from "rxjs";

export function onStreamUpdate<T>(observable: Observable<T>, onEventReceived: (event: T) => void) {
  useEffect(() => {
    const subscription = observable.subscribe(onEventReceived);
    return () => subscription.unsubscribe();
  }, [observable]);
}
