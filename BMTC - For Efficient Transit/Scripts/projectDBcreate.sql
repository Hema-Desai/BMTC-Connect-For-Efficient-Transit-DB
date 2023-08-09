/*1 - Create Table for Bus Type Spring23_S003_15_Bustype*/
CREATE TABLE Spring23_S003_15_Bustype (
    bustype VARCHAR(10) PRIMARY KEY,
    general_seats INT,
    female_seats INT,
    sr_citizen_seats INT,
    phy_handicapped_seats INT
);

/*2 - Create Table for STOP*/
CREATE TABLE Spring23_S003_15_Stop (
   stopid VARCHAR(8) PRIMARY KEY,
   stopname VARCHAR(50)
);

/*3 - Create Table for BUS DEPOT*/
CREATE TABLE Spring23_S003_15_Busdepot (
   depotid VARCHAR(8) PRIMARY KEY,
   FOREIGN KEY (depotid) REFERENCES Spring23_S003_15_Stop(stopid)
);

/*4 - Create Table for BUS*/
CREATE TABLE Spring23_S003_15_Bus (
    busid VARCHAR(8) PRIMARY KEY,
    bustype VARCHAR(10),
    depotid VARCHAR(8) NOT NULL,
    FOREIGN KEY (bustype) REFERENCES Spring23_S003_15_Bustype(bustype),
    FOREIGN KEY (depotid) REFERENCES Spring23_S003_15_Busdepot(depotid)
);


/*5 - Create Table for ROUTE*/
CREATE TABLE Spring23_S003_15_Route (
    routeid VARCHAR(8) PRIMARY KEY,
    rname VARCHAR(100),
    src_depot_id VARCHAR(8),
    dest_depot_id VARCHAR(8),
    FOREIGN KEY (src_depot_id) REFERENCES Spring23_S003_15_Busdepot(depotid),
    FOREIGN KEY (dest_depot_id) REFERENCES Spring23_S003_15_Busdepot(depotid)
);

/*6 - Create Table for ROUTE_HAS_STOPS*/
CREATE TABLE Spring23_S003_15_RouteHasStops (
    routeid VARCHAR(8),
    stopid VARCHAR(8),
    PRIMARY KEY(routeid, stopid),
    FOREIGN KEY (routeid) REFERENCES Spring23_S003_15_Route(routeid),
    FOREIGN KEY (stopid) REFERENCES Spring23_S003_15_Stop(stopid)
);

/*7 - Create Table for RUNS_ON*/
CREATE TABLE Spring23_S003_15_RunsOn (
    busid VARCHAR(8),
    routeid VARCHAR(8),
    PRIMARY KEY(busid, routeid),
    FOREIGN KEY (busid) REFERENCES Spring23_S003_15_Bus(busid),
    FOREIGN KEY (routeid) REFERENCES Spring23_S003_15_Route(routeid)
);

/*8 - Create Table for TICKET*/
CREATE TABLE Spring23_S003_15_Ticket (
    ticketid VARCHAR(8) PRIMARY KEY,
    t_type VARCHAR(3),
    t_datetime DATE,
    gender CHAR(1),
    busid VARCHAR(8),
    src_stop_id VARCHAR(8),
    dest_stop_id VARCHAR(8),
    cost INT,
    FOREIGN KEY (src_stop_id) REFERENCES Spring23_S003_15_Stop(stopid),
    FOREIGN KEY (dest_stop_id) REFERENCES Spring23_S003_15_Stop(stopid)
);