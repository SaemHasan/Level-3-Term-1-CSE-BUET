package com.company.mediator;

import com.company.organizations.Organization;

public interface Mediator {
    public void acceptRequest(Organization org, String type);
    public void provideService(String org);
}
