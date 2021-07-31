package com.company.server.observable;

import com.company.server.observer.Observer;
import com.company.server.observer.Observers;

import java.util.ArrayList;

public class Stocks implements Observable{

    private ArrayList<Observer> observersArrayList;
    private String id;
    private int count;
    private float price;

    public Stocks(String id, int count, float price) {
        this.id = id;
        this.count = count;
        this.price = price;
        observersArrayList = new ArrayList<>();
    }

    public String getId() {
        return id;
    }

    public void setId(String id) {
        this.id = id;
    }

    public int getCount() {
        return count;
    }

    public void setCount(int count) {
        this.count = count;
    }

    public float getPrice() {
        return price;
    }

    public void setPrice(float price) {
        this.price = price;
    }

    @Override
    public void add(Observers observer) {
        observersArrayList.add(observer);
    }

    @Override
    public void remove(Observers observer) {
        observersArrayList.remove(observer);
    }

    @Override
    public void Notify(String msg) {
        //System.out.println(observersArrayList.size());
        for(Observer observer : observersArrayList){
            observer.Update(msg);
        }
    }
}
