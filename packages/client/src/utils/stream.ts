import { useEffect, useState } from "react";
import { Observable } from "rxjs";

// This only receives new events, it doesn't replay all events from teh begining of the stream I think
// useComponentUpdate may be better?
export function onStreamUpdate<T>(observable: Observable<T>, onEventReceived: (event: T) => void) {
  useEffect(() => {
    const subscription = observable.subscribe(onEventReceived);
    return () => subscription.unsubscribe();
  }, [observable]);
}

// Note: only use this for rxjs streams. If you want to read a component's update, use useComponentUpdate
export function useStream<T>(stream: Observable<T>, defaultValue?: T) {
  const [state, setState] = useState<T | undefined>(defaultValue);

  useEffect(() => {
    const sub = stream.subscribe((newState) => setState(newState));
    return () => sub?.unsubscribe();
  }, []);

  return state;
}
