package com.company.menuitem.decorator.appetizerDecorator;

import com.company.menuitem.MenuItem;

public class OnionRings extends AppetizerDecorator {

    public OnionRings(MenuItem item) {
        super(item);
    }

    public OnionRings(MenuItem item, double price) {
        super(item, price);
    }
}
