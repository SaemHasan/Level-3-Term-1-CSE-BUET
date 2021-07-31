package com.company.server.observable;

import com.company.server.observer.Observers;

public interface Observable {
    public void add(Observers observer);
    public void remove(Observers observer);
    public void Notify(String msg);

}
