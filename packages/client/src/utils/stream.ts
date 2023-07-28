import { useEffect } from "react";
import { Observable } from "rxjs";

// This only receives new events, it doesn't replay all events from teh begining of the stream I think
// useComponentUpdate may be better?
export function onStreamUpdate<T>(observable: Observable<T>, onEventReceived: (event: T) => void) {
  useEffect(() => {
    const subscription = observable.subscribe(onEventReceived);
    return () => subscription.unsubscribe();
  }, [observable]);
}
