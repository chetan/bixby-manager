SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='TRADITIONAL';


-- -----------------------------------------------------
-- Table `tenants`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `tenants` ;

CREATE  TABLE IF NOT EXISTS `tenants` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `name` VARCHAR(255) NULL ,
  `password` CHAR(32) NULL ,
  PRIMARY KEY (`id`) )
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `orgs`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `orgs` ;

CREATE  TABLE IF NOT EXISTS `orgs` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `tenant_id` INT UNSIGNED NULL ,
  `name` VARCHAR(255) NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_orgs_tenants1`
    FOREIGN KEY (`tenant_id` )
    REFERENCES `tenants` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE UNIQUE INDEX `id_UNIQUE` ON `orgs` (`id` ASC) ;

CREATE INDEX `fk_orgs_tenants1` ON `orgs` (`tenant_id` ASC) ;


-- -----------------------------------------------------
-- Table `hosts`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `hosts` ;

CREATE  TABLE IF NOT EXISTS `hosts` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `org_id` INT UNSIGNED NOT NULL ,
  `ip` VARCHAR(16) NULL ,
  `hostname` VARCHAR(255) NULL ,
  `alias` VARCHAR(255) NULL ,
  `desc` VARCHAR(255) NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_hosts_orgs1`
    FOREIGN KEY (`org_id` )
    REFERENCES `orgs` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_hosts_orgs1` ON `hosts` (`org_id` ASC) ;


-- -----------------------------------------------------
-- Table `agents`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `agents` ;

CREATE  TABLE IF NOT EXISTS `agents` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `host_id` INT UNSIGNED NOT NULL ,
  `uuid` VARCHAR(255) NULL ,
  `ip` VARCHAR(16) NULL ,
  `port` SMALLINT UNSIGNED NULL DEFAULT 18000 ,
  `public_key` VARCHAR(426) NULL ,
  `status` SMALLINT UNSIGNED NOT NULL DEFAULT 0 ,
  `created_at` DATETIME NULL ,
  `updated_at` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_agents_hosts1`
    FOREIGN KEY (`host_id` )
    REFERENCES `hosts` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE UNIQUE INDEX `id_UNIQUE` ON `agents` (`id` ASC) ;

CREATE INDEX `fk_agents_hosts1` ON `agents` (`host_id` ASC) ;


-- -----------------------------------------------------
-- Table `users`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `users` ;

CREATE  TABLE IF NOT EXISTS `users` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `org_id` INT UNSIGNED NOT NULL ,
  `username` VARCHAR(255) NOT NULL ,
  `name` VARCHAR(255) NULL ,
  `email` VARCHAR(255) NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_users_orgs1`
    FOREIGN KEY (`org_id` )
    REFERENCES `orgs` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_users_orgs1` ON `users` (`org_id` ASC) ;


-- -----------------------------------------------------
-- Table `repos`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `repos` ;

CREATE  TABLE IF NOT EXISTS `repos` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `org_id` INT UNSIGNED NULL ,
  `name` VARCHAR(255) NULL ,
  `uri` VARCHAR(255) NULL ,
  `branch` VARCHAR(255) NULL ,
  `created_at` DATETIME NULL ,
  `updated_at` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_repos_orgs1`
    FOREIGN KEY (`org_id` )
    REFERENCES `orgs` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE UNIQUE INDEX `id_UNIQUE` ON `repos` (`id` ASC) ;

CREATE INDEX `fk_repos_orgs1` ON `repos` (`org_id` ASC) ;


-- -----------------------------------------------------
-- Table `commands`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `commands` ;

CREATE  TABLE IF NOT EXISTS `commands` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `repo_id` INT UNSIGNED NULL ,
  `name` VARCHAR(255) NULL ,
  `bundle` VARCHAR(255) NULL ,
  `command` VARCHAR(255) NULL ,
  `options` TEXT NULL ,
  `updated_at` DATETIME NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_commands_repos1`
    FOREIGN KEY (`repo_id` )
    REFERENCES `repos` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_commands_repos1` ON `commands` (`repo_id` ASC) ;


-- -----------------------------------------------------
-- Table `resources`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `resources` ;

CREATE  TABLE IF NOT EXISTS `resources` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `host_id` INT UNSIGNED NOT NULL ,
  `name` VARCHAR(255) NULL ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_resources_hosts1`
    FOREIGN KEY (`host_id` )
    REFERENCES `hosts` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_resources_hosts1` ON `resources` (`host_id` ASC) ;


-- -----------------------------------------------------
-- Table `checks`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `checks` ;

CREATE  TABLE IF NOT EXISTS `checks` (
  `id` INT UNSIGNED NOT NULL AUTO_INCREMENT ,
  `resource_id` INT UNSIGNED NOT NULL ,
  `agent_id` INT UNSIGNED NOT NULL ,
  `command_id` INT UNSIGNED NOT NULL ,
  `args` TEXT NULL ,
  `normal_interval` SMALLINT UNSIGNED NULL ,
  `retry_interval` SMALLINT UNSIGNED NULL ,
  `plot` TINYINT(1)  NULL ,
  `enabled` TINYINT(1)  NULL DEFAULT false ,
  PRIMARY KEY (`id`) ,
  CONSTRAINT `fk_checks_agents1`
    FOREIGN KEY (`agent_id` )
    REFERENCES `agents` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_checks_commands1`
    FOREIGN KEY (`command_id` )
    REFERENCES `commands` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION,
  CONSTRAINT `fk_checks_resources1`
    FOREIGN KEY (`resource_id` )
    REFERENCES `resources` (`id` )
    ON DELETE NO ACTION
    ON UPDATE NO ACTION)
ENGINE = InnoDB;

CREATE INDEX `fk_checks_agents1` ON `checks` (`agent_id` ASC) ;

CREATE INDEX `fk_checks_commands1` ON `checks` (`command_id` ASC) ;

CREATE INDEX `fk_checks_resources1` ON `checks` (`resource_id` ASC) ;



SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
