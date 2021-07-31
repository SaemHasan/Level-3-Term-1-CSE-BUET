package com.company.menuitem.pizza;

public class Veggi_Pizza implements Pizza {
    private double price;

    public Veggi_Pizza(double price) {
        this.price = price;
    }

    public Veggi_Pizza() {
        price=500;
    }

    @Override
    public double getPrice() {
        return price;
    }
}
