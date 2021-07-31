package com.company.menuitem.pizza;

public class Beef_Pizza implements Pizza {

    private double price;

    public Beef_Pizza() {
        price = 700;
    }

    public Beef_Pizza(double price) {
        this.price = price;
    }

    @Override
    public double getPrice() {
        return price;
    }
}
