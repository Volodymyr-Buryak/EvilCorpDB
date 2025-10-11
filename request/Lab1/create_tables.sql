-- a. Створення БД згідно з розробленою в роботі №1 ER-моделлю;
CREATE DATABASE insure_company_db;

/* b. створення таблиць в БД засобами мови SQL. Передбачити наявність
   обмежень для підтримки цілісності та коректності даних, котрі зберігаються та вводяться: */

-- Таблиця [insurance_agents]
CREATE TABLE insurance_agents
(
    agent_id    INT GENERATED ALWAYS AS IDENTITY,
    first_name  VARCHAR(50)         NOT NULL,
    last_name   VARCHAR(50)         NOT NULL,
    patronymic  VARCHAR(50),
    email       VARCHAR(100) UNIQUE NOT NULL,
    phone       VARCHAR(20) UNIQUE  NOT NULL,
    hire_date   DATE                NOT NULL DEFAULT CURRENT_DATE,
    address_id  INT                 NOT NULL,
    branch_id   INT,
    passport_id INT UNIQUE          NOT NULL
);
-- Встановлення первинного ключа
ALTER TABLE insurance_agents
    ADD CONSTRAINT pk_insurance_agents_agent_id PRIMARY KEY (agent_id);
-- Перевірка дати найму (не може бути в майбутньому)
ALTER TABLE insurance_agents
    ADD CONSTRAINT check_insurance_agents_hire_date
        CHECK (hire_date <= CURRENT_DATE);


-- Таблиця [addresses]
CREATE TABLE addresses
(
    address_id     INT GENERATED ALWAYS AS IDENTITY,
    country        VARCHAR(32)  NOT NULL,
    region         VARCHAR(50),
    city           VARCHAR(50)  NOT NULL,
    street_address VARCHAR(128) NOT NULL,
    building_info  VARCHAR(128),
    postal_code    VARCHAR(10)
);
-- Встановлення первинного ключа для [addresses]
ALTER TABLE addresses
    ADD CONSTRAINT fk_addresses_address_id PRIMARY KEY (address_id);

-- Таблиця [passports]
CREATE TABLE passports
(
    passport_id         INT GENERATED ALWAYS AS IDENTITY,
    passport_series     VARCHAR(10)        NOT NULL,
    passport_number     VARCHAR(20)        NOT NULL,
    passport_issued_by  VARCHAR(50)        NOT NULL,
    passport_issue_date DATE               NOT NULL,
    tax_number          VARCHAR(20) UNIQUE NOT NULL
);
-- Встановлення первинного ключа для [passports]
ALTER TABLE passports
    ADD CONSTRAINT pk_passports_passport_id PRIMARY KEY (passport_id);
-- Перевірка дати видачі (не може бути в майбутньому)
ALTER TABLE passports
    ADD CONSTRAINT check_passport_passport_issue_date
        CHECK (passport_issue_date <= CURRENT_DATE);
-- Унікальна комбінація серії та номера паспорта
ALTER TABLE passports
    ADD CONSTRAINT uq_passport_passport_series UNIQUE (passport_series, passport_number);


-- Таблиця [branches]
CREATE TABLE branches
(
    branch_id    INT GENERATED ALWAYS AS IDENTITY,
    name         VARCHAR(50)        NOT NULL,
    phone        VARCHAR(20) UNIQUE NOT NULL,
    email        VARCHAR(100) UNIQUE,
    opening_date DATE               NOT NULL,
    address_id   INT UNIQUE         NOT NULL
);
-- Встановлення первинного ключа для [branches]
ALTER TABLE branches
    ADD CONSTRAINT pk_branches_branch_id PRIMARY KEY (branch_id);
-- Перевірка дати відкриття (не може бути в майбутньому)
ALTER TABLE branches
    ADD CONSTRAINT check_branches_opening_date
        CHECK (opening_date <= CURRENT_DATE);


-- Таблиця [clients]
CREATE TABLE clients
(
    clients_id        INT GENERATED ALWAYS AS IDENTITY,
    first_name        VARCHAR(50)        NOT NULL,
    last_name         VARCHAR(50)        NOT NULL,
    patronymic        VARCHAR(50),
    phone             VARCHAR(20) UNIQUE NOT NULL,
    email             VARCHAR(100) UNIQUE,
    birth_date        DATE               NOT NULL,
    registration_date DATE               NOT NULL DEFAULT CURRENT_DATE,
    address_id        INT                NOT NULL,
    passport_id       INT UNIQUE         NOT NULL
);
-- Встановлення первинного ключа для [clients]
ALTER TABLE clients
    ADD CONSTRAINT pk_clients_clients_id PRIMARY KEY (clients_id);
-- Перевірка дати реєстрації (не може бути в майбутньому)
ALTER TABLE clients
    ADD CONSTRAINT check_clients_registration_date
        CHECK (registration_date <= CURRENT_DATE);
-- Перевірка дати народження (не може бути в майбутньому)
ALTER TABLE clients
    ADD CONSTRAINT check_clients_birth_date
        CHECK (birth_date <= CURRENT_DATE);
-- Потрібно зробити перевірку, що клієнту на момент реєстрації має бути не менше 18 років
ALTER TABLE clients
    ADD CONSTRAINT chek_clients_age
        CHECK (birth_date <= CURRENT_DATE - INTERVAL '18 years');
-- Реєстрація після народження
ALTER TABLE clients
    ADD CONSTRAINT check_clients_registration_date_after_birth
        CHECK (registration_date >= birth_date);


-- Таблиця [contracts]
CREATE TABLE contracts
(
    contract_id        INT GENERATED ALWAYS AS IDENTITY,
    contract_date      DATE           NOT NULL DEFAULT CURRENT_DATE,
    start_date         DATE           NOT NULL,
    end_date           DATE           NOT NULL,
    insurance_sum      NUMERIC(12, 2) NOT NULL,
    tariff_rate        NUMERIC(5, 4)  NOT NULL,
    insurance_payment  NUMERIC(12, 2) NOT NULL,
    client_id          INT            NOT NULL,
    agent_id           INT            NOT NULL,
    branch_id          INT            NOT NULL,
    type_id            INT            NOT NULL
);
-- Встановлення первинного ключа для [contracts]
ALTER TABLE contracts
    ADD CONSTRAINT pk_contracts_contract_id PRIMARY KEY (contract_id);
-- Перевіряємо, що дата початку не раніше дати укладення
ALTER TABLE contracts
    ADD CONSTRAINT check_contracts_start_date
    CHECK (start_date >= contract_date);
-- Перевіряємо, що дата закінчення пізніше дати початку
ALTER TABLE contracts
    ADD CONSTRAINT check_contracts_end_date
    CHECK (end_date > start_date);
-- Перевірка, що страхова сума додатна
ALTER TABLE contracts
    ADD CONSTRAINT check_contracts_insurance_sum
    CHECK (insurance_sum > 0);
-- Перевірка, що тарифна ставка в межах 0% - 100%
ALTER TABLE contracts
    ADD CONSTRAINT check_contracts_tariff_rate
    CHECK (tariff_rate > 0 AND tariff_rate <= 1);
-- Перевірка, що страхова виплата додатна
ALTER TABLE contracts
    ADD CONSTRAINT check_contracts_insurance_payment
    CHECK (insurance_payment > 0);


-- Таблиця [insurance_types]
CREATE TABLE insurance_types
(
    type_id         INT GENERATED ALWAYS AS IDENTITY,
    type_name       VARCHAR(100) UNIQUE NOT NULL,
    description     TEXT NOT NULL,
    commission_rate NUMERIC(5, 4) NOT NULL
);

-- Встановлення первинного ключа для [insurance_types]
ALTER TABLE insurance_types
    ADD CONSTRAINT pk_insurance_types_type_id
        PRIMARY KEY (type_id);
-- Перевірка, що ставка комісії в межах 0% - 100%
ALTER TABLE insurance_types
    ADD CONSTRAINT check_insurance_types_commission_rate
    CHECK (commission_rate > 0 AND commission_rate <= 1);



-- c. Встановлення зв’язків між таблицями засобами мови SQL:
-- Встановлення зв'язку між insurance_agents та addresses
ALTER TABLE insurance_agents
    ADD CONSTRAINT fk_agent_address
        FOREIGN KEY (address_id) REFERENCES addresses (address_id);

-- Встановлення зв'язку між insurance_agents та branches
ALTER TABLE insurance_agents
    ADD CONSTRAINT fk_agent_branch
        FOREIGN KEY (branch_id) REFERENCES branches (branch_id);

-- Встановлення зв'язку між insurance_agents та passports
ALTER TABLE insurance_agents
    ADD CONSTRAINT fk_insurance_agents_passport_id
        FOREIGN KEY (passport_id) REFERENCES passports (passport_id);

-- Встановлення зв'язку між branches та addresses
ALTER TABLE branches
    ADD CONSTRAINT fk_branch_address_id
        FOREIGN KEY (address_id) REFERENCES addresses (address_id);

-- Встановлення зв'язку між clients та addresses
ALTER TABLE clients
    ADD CONSTRAINT fk_clients_address_id
        FOREIGN KEY (address_id) REFERENCES addresses (address_id);

-- Встановлення зв'язку між clients та passports
ALTER TABLE clients
    ADD CONSTRAINT fk_clients_passport_id
        FOREIGN KEY (passport_id) REFERENCES passports (passport_id);

-- Встановлення зв'язку між contracts та clients
ALTER TABLE contracts
    ADD CONSTRAINT fk_contracts_client_id
        FOREIGN KEY (client_id) REFERENCES clients (clients_id);

-- Встановлення зв'язку між contracts та insurance_agents
ALTER TABLE contracts
    ADD CONSTRAINT fk_contracts_agent_id
        FOREIGN KEY (agent_id) REFERENCES insurance_agents (agent_id);

-- Встановлення зв'язку між contracts та branches
ALTER TABLE contracts
    ADD CONSTRAINT fk_contracts_branch_id
        FOREIGN KEY (branch_id) REFERENCES branches (branch_id);

-- Встановлення зв'язку між contracts та insurance_types
ALTER TABLE contracts
    ADD CONSTRAINT fk_contracts_type_id
        FOREIGN KEY (type_id) REFERENCES insurance_types (type_id);



